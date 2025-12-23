import 'package:flutter/material.dart';
import './api/gemini_service.dart';
import 'app_drawer.dart';
import './database_helper.dart';

class AssistantPage extends StatefulWidget {
  const AssistantPage({super.key});

  @override
  State<AssistantPage> createState() => _AssistantPageState();
}

class _AssistantPageState extends State<AssistantPage> {
  final TextEditingController _controller = TextEditingController();
  final GeminiService _geminiService = GeminiService();
  final List<Map<String, String>> _messages = []; // 'user' or 'ai'
  bool _isLoading = false;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadMessagesForSelectedDate();
  }

  Future<void> _loadMessagesForSelectedDate() async {
    final dateString = _selectedDate.toIso8601String().substring(0, 10);
    final msgs = await DatabaseHelper.instance.getMessagesForDate(dateString);
    setState(() {
      _messages.clear();
      _messages.addAll(msgs.map((m) => {'role': m.role, 'content': m.content}));
    });
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      await _loadMessagesForSelectedDate();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _sendMessage() async {
    if (_controller.text.trim().isEmpty) return;

    final userMessage = _controller.text.trim();
    _controller.clear();

    final dateString = _selectedDate.toIso8601String().substring(0, 10);
    final userMsg = AssistantMessage(
      date: dateString,
      role: 'user',
      content: userMessage,
      timestamp: DateTime.now().toIso8601String(),
    );

    try {
      // Optimistically add the user's message to UI and persist it
      setState(() {
        _messages.add({'role': 'user', 'content': userMessage});
        _isLoading = true;
      });
      await DatabaseHelper.instance.insertAssistantMessage(userMsg);

      // Fetch events for the selected date to include as context
      final List<Event> events = await DatabaseHelper.instance.getEventsForDate(
        _selectedDate,
      );
      String eventContext;
      if (events.isEmpty) {
        eventContext = "No events scheduled for $dateString.";
      } else {
        final buffer = StringBuffer();
        for (var event in events) {
          buffer.writeln(
            "- ${event.title} (${event.startTime} - ${event.endTime})",
          );
          if (event.description.isNotEmpty)
            buffer.writeln("  Description: ${event.description}");
          if (event.location.isNotEmpty)
            buffer.writeln("  Location: ${event.location}");
        }
        eventContext = buffer.toString();
      }

      // Fetch last 10 messages for context
      final List<AssistantMessage> history = await DatabaseHelper.instance
          .getLastMessagesForDate(dateString, 10);
      final histBuffer = StringBuffer();
      for (var m in history) {
        final who = m.role == 'user' ? 'User' : 'AI';
        histBuffer.writeln("$who: ${m.content}");
      }

      final prompt =
          "Date: $dateString\nEvents:\n$eventContext\n\nConversation history:\n${histBuffer.toString()}\nNew question: $userMessage";

      // Call Gemini Service with events and recent messages as context
      final response = await _geminiService.generateContent(prompt);

      setState(() {
        _messages.add({'role': 'ai', 'content': response});
      });

      final aiMsg = AssistantMessage(
        date: dateString,
        role: 'ai',
        content: response,
        timestamp: DateTime.now().toIso8601String(),
      );
      await DatabaseHelper.instance.insertAssistantMessage(aiMsg);
    } catch (e) {
      final errorText = 'Error: $e';
      setState(() {
        _messages.add({'role': 'ai', 'content': errorText});
      });
      final aiErr = AssistantMessage(
        date: dateString,
        role: 'ai',
        content: errorText,
        timestamp: DateTime.now().toIso8601String(),
      );
      await DatabaseHelper.instance.insertAssistantMessage(aiErr);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Assistant')),
      drawer: AppDrawer(
        currentRoute: 'assistant',
        onOpenDayView: (DateTime date) {},
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 12.0,
              vertical: 8.0,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Selected date: ${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}',
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: _pickDate,
                ),
                TextButton(
                  onPressed: () async {
                    setState(() {
                      _selectedDate = DateTime.now();
                    });
                    await _loadMessagesForSelectedDate();
                  },
                  child: const Text('Today'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isUser = message['role'] == 'user';
                // Use blue for AI message bubbles, keep user as primaryContainer
                final bubbleColor = isUser
                    ? theme.colorScheme.primaryContainer
                    : Colors.blue[50];
                final textColor = isUser
                    ? theme.colorScheme.onPrimaryContainer
                    : Colors.blue[900];
                return Align(
                  alignment: isUser
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4.0),
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: bubbleColor,
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Text(
                      message['content'] ?? '',
                      style: TextStyle(color: textColor),
                    ),
                  ),
                );
              },
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Center(child: CircularProgressIndicator()),
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Ask something...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
