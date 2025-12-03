import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import './database_helper.dart'; // For Event type
import './add_event_page.dart'; // Import AddEventPage
import './event_details_page.dart'; // Import EventDetailsPage
import './notification_service.dart'; // Import notification service
import './app_drawer.dart'; // Import AppDrawer

class DayEventsScreen extends StatefulWidget {
  final DateTime selectedDay;
  final List<Event> events;
  final double hourHeight;
  final int minHour;
  final int maxHour;
  final double timeLabelWidth;
  final Function(Event) onEventTapped;
  final Color? backgroundColor;
  final VoidCallback? onMasterListShouldUpdate;
  final VoidCallback? onViewSwitch;
  final bool isWeekView;
  final VoidCallback? onToggleTheme;
  final ThemeMode? themeMode;

  const DayEventsScreen({
    super.key,
    required this.selectedDay,
    required this.events,
    required this.hourHeight,
    required this.minHour,
    required this.maxHour,
    required this.timeLabelWidth,
    required this.onEventTapped,
    this.backgroundColor,
    this.onMasterListShouldUpdate,
    this.onViewSwitch,
    this.isWeekView = false,
    this.onToggleTheme,
    this.themeMode,
  });

  @override
  State<DayEventsScreen> createState() => _DayEventsScreenState();
}

class _DayEventsScreenState extends State<DayEventsScreen> {
  late DateTime _currentDay;
  late List<Event> _dayEvents;
  final dbHelper = DatabaseHelper.instance;

  @override
  void initState() {
    super.initState();
    _currentDay = widget.selectedDay;
    _loadDayEvents();
  }

  Future<void> _loadDayEvents() async {
    final events = await dbHelper.getEventsForDate(_currentDay);
    if (mounted) {
      setState(() {
        _dayEvents = events;
      });
    }
  }

  void _goToPreviousDay() {
    setState(() {
      _currentDay = _currentDay.subtract(const Duration(days: 1));
    });
    _loadDayEvents();
  }

  void _goToNextDay() {
    setState(() {
      _currentDay = _currentDay.add(const Duration(days: 1));
    });
    _loadDayEvents();
  }

  void _addEvent() async {
    final Event? newEvent = await Navigator.of(context).push<Event>(
      MaterialPageRoute(builder: (context) => AddEventPage(date: _currentDay)),
    );

    if (newEvent != null && newEvent.id != null && mounted) {
      await _loadDayEvents();
      await scheduleEventNotification(newEvent);
      widget.onMasterListShouldUpdate?.call();
    }
  }

  Future<void> _navigateToEventDetails(Event event) async {
    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EventDetailsPage(
          event: event,
          onEventChanged: (Event? updatedEvent) async {
            if (mounted) {
              await _loadDayEvents();

              if (event.id != null) {
                await cancelEventNotification(event.id!);
              }
              if (updatedEvent != null && updatedEvent.id != null) {
                await scheduleEventNotification(updatedEvent);
              }
              widget.onMasterListShouldUpdate?.call();
            }
          },
        ),
      ),
    );
  }

  Widget _buildTimeLabelStack(BuildContext context) {
    final theme = Theme.of(context);
    final timeLabelColor = theme.colorScheme.onSurface;
    List<Widget> timeLabels = [];

    for (int hour = widget.minHour; hour <= widget.maxHour; hour++) {
      timeLabels.add(
        Positioned(
          top: (hour - widget.minHour) * widget.hourHeight,
          left: 0,
          width: widget.timeLabelWidth,
          height: widget.hourHeight,
          child: Container(
            padding: EdgeInsets.zero,
            margin: EdgeInsets.zero,
            alignment: Alignment.topCenter,
            child: Text(
              DateFormat('HH').format(DateTime(2000, 1, 1, hour)),
              style: theme.textTheme.labelSmall?.copyWith(
                fontSize: 10,
                color: timeLabelColor.withOpacity(0.7),
                height: 1.0,
              ),
            ),
          ),
        ),
      );
    }
    return Stack(children: timeLabels);
  }

  Widget _buildDayScheduleStack(BuildContext context, double columnWidth) {
    final theme = Theme.of(context);
    List<Widget> stackChildren = [];

    // Add hour dividers and half-hour dotted lines
    for (int hour = widget.minHour; hour <= widget.maxHour; hour++) {
      // Full hour divider
      stackChildren.add(
        Positioned(
          top: (hour - widget.minHour) * widget.hourHeight,
          left: 0,
          width: columnWidth,
          child: Divider(height: 1, thickness: 0.5, color: theme.dividerColor),
        ),
      );

      // Half-hour dotted line
      if (hour < widget.maxHour) {
        stackChildren.add(
          Positioned(
            top:
                (hour - widget.minHour) * widget.hourHeight +
                widget.hourHeight / 2,
            left: -widget.timeLabelWidth,
            width: columnWidth + widget.timeLabelWidth,
            child: CustomPaint(
              size: Size(columnWidth + widget.timeLabelWidth, 1),
              painter: DottedLinePainter(
                color: theme.dividerColor.withOpacity(0.5),
              ),
            ),
          ),
        );
      }
    }

    // Sort and add events for current day
    final dayKey = DateTime(
      _currentDay.year,
      _currentDay.month,
      _currentDay.day,
    );
    final dayEvents = _dayEvents.where((event) {
      final eventDate = DateTime(
        event.date.year,
        event.date.month,
        event.date.day,
      );
      return eventDate == dayKey;
    }).toList();

    dayEvents.sort(
      (a, b) =>
          (a.startTimeAsTimeOfDay.hour * 60 + a.startTimeAsTimeOfDay.minute)
              .compareTo(
                b.startTimeAsTimeOfDay.hour * 60 +
                    b.startTimeAsTimeOfDay.minute,
              ),
    );

    for (var event in dayEvents) {
      final startMinutes =
          event.startTimeAsTimeOfDay.hour * 60 +
          event.startTimeAsTimeOfDay.minute;
      final endMinutes =
          event.endTimeAsTimeOfDay.hour * 60 + event.endTimeAsTimeOfDay.minute;
      final minHourMinutes = widget.minHour * 60;

      final topPosition =
          ((startMinutes - minHourMinutes) / 60.0) * widget.hourHeight;
      final eventDurationInMinutes = endMinutes - startMinutes;
      double eventHeight = (eventDurationInMinutes / 60.0) * widget.hourHeight;

      if (eventHeight < widget.hourHeight / 3) {
        eventHeight = widget.hourHeight / 3;
      }
      if (topPosition < 0) continue;
      if (topPosition + eventHeight >
          (widget.maxHour - widget.minHour + 1) * widget.hourHeight) {
        eventHeight =
            ((widget.maxHour - widget.minHour + 1) * widget.hourHeight) -
            topPosition;
      }
      if (eventHeight <= 0) continue;

      stackChildren.add(
        Positioned(
          top: topPosition,
          left: 2.0,
          width: columnWidth - 4.0,
          height: eventHeight,
          child: GestureDetector(
            onTap: () => _navigateToEventDetails(event),
            child: Container(
              padding: const EdgeInsets.all(4.0),
              margin: const EdgeInsets.only(bottom: 1.0),
              decoration: BoxDecoration(
                color: theme.colorScheme.onPrimary.withOpacity(0.6),
                borderRadius: BorderRadius.circular(4.0),
              ),
              child: Text(
                event.title,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: eventHeight > 25 ? 2 : 1,
              ),
            ),
          ),
        ),
      );
    }

    // Add current time indicator if today
    final now = DateTime.now();
    final currentDate = DateTime(now.year, now.month, now.day);
    if (_currentDay.year == currentDate.year &&
        _currentDay.month == currentDate.month &&
        _currentDay.day == currentDate.day) {
      final currentTimeInMinutes = now.hour * 60 + now.minute;
      final minHourMinutes = widget.minHour * 60;
      final maxHourMinutes = widget.maxHour * 60 + 59;

      if (currentTimeInMinutes >= minHourMinutes &&
          currentTimeInMinutes <= maxHourMinutes) {
        final topOffset =
            ((currentTimeInMinutes - minHourMinutes) / 60.0) *
            widget.hourHeight;
        final double totalScheduleHeight =
            (widget.maxHour - widget.minHour + 1) * widget.hourHeight;
        const double indicatorHeight = 12.0;

        if (topOffset >= 0 && topOffset <= totalScheduleHeight) {
          stackChildren.add(
            Positioned(
              top: topOffset - (indicatorHeight / 2),
              left: 0,
              width: columnWidth,
              height: indicatorHeight,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    top: indicatorHeight / 2 - 0.5,
                    left: 0,
                    right: 0,
                    child: Container(height: 1.0, color: Colors.red),
                  ),
                  Positioned(
                    top: 0,
                    right: 2,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 3.0,
                        vertical: 1.0,
                      ),
                      decoration: BoxDecoration(
                        color: theme.canvasColor.withOpacity(0.75),
                        borderRadius: BorderRadius.circular(2.0),
                      ),
                      child: Text(
                        DateFormat.jm().format(now),
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      }
    }

    return Stack(children: stackChildren);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final borderColor = theme.dividerColor;
    final totalScrollableHeight =
        (widget.maxHour - widget.minHour + 1) * widget.hourHeight;

    final dayDate = DateFormat.yMMMd().format(_currentDay);

    return Scaffold(
      appBar: AppBar(
        title: Text(dayDate),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.today, color: theme.colorScheme.primary),
            onPressed: () {
              setState(() {
                _currentDay = DateTime(
                  DateTime.now().year,
                  DateTime.now().month,
                  DateTime.now().day,
                );
              });
              _loadDayEvents();
            },
          ),
        ],
      ),
      drawer: AppDrawer(
        currentRoute: 'day',
        onViewSwitch: widget.onViewSwitch,
        isWeekView: widget.isWeekView,
        onToggleTheme: widget.onToggleTheme,
        themeMode: widget.themeMode,
        selectedDate: _currentDay,
        events: _dayEvents,
        hourHeight: widget.hourHeight,
        minHour: widget.minHour,
        maxHour: widget.maxHour,
        timeLabelWidth: widget.timeLabelWidth,
        onEventTapped: widget.onEventTapped,
      ),
      body: GestureDetector(
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity! > 0) {
            _goToPreviousDay();
          } else if (details.primaryVelocity! < 0) {
            _goToNextDay();
          }
        },
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                DateFormat('EEEE, MMM d').format(_currentDay),
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: SizedBox(
                  height: totalScrollableHeight,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: widget.timeLabelWidth,
                        height: totalScrollableHeight,
                        child: _buildTimeLabelStack(context),
                      ),
                      Expanded(
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            return Container(
                              height: totalScrollableHeight,
                              decoration: BoxDecoration(
                                color: widget.backgroundColor,
                                border: Border(
                                  left: BorderSide(
                                    color: borderColor,
                                    width: 0.5,
                                  ),
                                ),
                              ),
                              child: _buildDayScheduleStack(
                                context,
                                constraints.maxWidth,
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addEvent,
        tooltip: 'Add Event',
        child: Icon(Icons.add, color: theme.colorScheme.onPrimary),
        backgroundColor: theme.colorScheme.outlineVariant,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25.0),
        ),
      ),
    );
  }
}

class DottedLinePainter extends CustomPainter {
  final Color color;

  DottedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const double dashWidth = 4.0;
    const double dashSpace = 2.0;
    double startX = 0;

    while (startX < size.width) {
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
