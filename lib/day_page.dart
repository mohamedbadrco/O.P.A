import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import './database_helper.dart'; // For Event type

class DayPageContent extends StatelessWidget {
  final DateTime date;
  final List<Event> events;
  final double hourHeight;
  final int minHour;
  final int maxHour;
  final double timeLabelWidth;
  final Function(Event) onEventTapped;
  final VoidCallback onGoToPreviousDay;
  final VoidCallback onGoToNextDay;
  final Color? currentTimeColor;

  const DayPageContent({
    super.key,
    required this.date,
    required this.events,
    required this.onEventTapped,
    required this.onGoToPreviousDay,
    required this.onGoToNextDay,
    this.hourHeight = 60.0,
    this.minHour = 0,
    this.maxHour = 23,
    this.timeLabelWidth = 50.0,
    this.currentTimeColor,
  });

  Widget _buildTimeLabels(BuildContext context) {
    final theme = Theme.of(context);
    final List<Widget> labels = [];
    for (int hour = minHour; hour <= maxHour; hour++) {
      labels.add(
        Positioned(
          top: (hour - minHour) * hourHeight,
          left: 0,
          width: timeLabelWidth,
          height: hourHeight,
          child: Container(
            padding: EdgeInsets.zero,
            alignment: Alignment.centerLeft,
            child: Text(
              DateFormat('HH').format(DateTime(2000, 1, 1, hour)),
              style: theme.textTheme.labelSmall?.copyWith(
                fontSize: 10,
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ),
        ),
      );
    }
    return Stack(children: labels);
  }

  Widget _buildScheduleStack(BuildContext context, double columnWidth) {
    final theme = Theme.of(context);
    final List<Widget> children = [];

    // Hour dividers
    for (int hour = minHour; hour <= maxHour; hour++) {
      children.add(
        Positioned(
          top: (hour - minHour) * hourHeight,
          left: 0,
          width: columnWidth,
          child: Divider(height: 1, thickness: 0.5, color: theme.dividerColor),
        ),
      );
    }

    // Events
    final sorted = List<Event>.from(events)
      ..sort((a, b) {
        final aMin =
            a.startTimeAsTimeOfDay.hour * 60 + a.startTimeAsTimeOfDay.minute;
        final bMin =
            b.startTimeAsTimeOfDay.hour * 60 + b.startTimeAsTimeOfDay.minute;
        return aMin.compareTo(bMin);
      });

    for (final event in sorted) {
      final startMin =
          event.startTimeAsTimeOfDay.hour * 60 +
          event.startTimeAsTimeOfDay.minute;
      final endMin =
          event.endTimeAsTimeOfDay.hour * 60 + event.endTimeAsTimeOfDay.minute;
      final minHourMin = minHour * 60;
      final top = ((startMin - minHourMin) / 60.0) * hourHeight;
      double height = ((endMin - startMin) / 60.0) * hourHeight;
      if (height < hourHeight / 3) height = hourHeight / 3;
      if (top < 0) continue;
      final totalHeight = (maxHour - minHour + 1) * hourHeight;
      if (top + height > totalHeight) height = totalHeight - top;
      if (height <= 0) continue;

      children.add(
        Positioned(
          top: top,
          left: 4,
          width: columnWidth - 8,
          height: height,
          child: GestureDetector(
            onTap: () => onEventTapped(event),
            child: Container(
              padding: const EdgeInsets.all(6.0),
              decoration: BoxDecoration(
                color: theme.colorScheme.onPrimary.withOpacity(0.6),
                borderRadius: BorderRadius.circular(6.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: height > 30 ? 2 : 1,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "${DateFormat.jm().format(DateTime(0, 0, 0, event.startTimeAsTimeOfDay.hour, event.startTimeAsTimeOfDay.minute))} - ${DateFormat.jm().format(DateTime(0, 0, 0, event.endTimeAsTimeOfDay.hour, event.endTimeAsTimeOfDay.minute))}",
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 10,
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // Current time indicator (only if date is today)
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    if (today == target) {
      final currentMinutes = now.hour * 60 + now.minute;
      final minHourMin = minHour * 60;
      final maxHourMin = maxHour * 60 + 59;
      if (currentMinutes >= minHourMin && currentMinutes <= maxHourMin) {
        final topOffset = ((currentMinutes - minHourMin) / 60.0) * hourHeight;
        const double indicatorHeight = 14.0;
        children.add(
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
                  child: Container(
                    height: 1.0,
                    color: currentTimeColor ?? Colors.red,
                  ),
                ),
                Positioned(
                  top: 0,
                  right: 4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: theme.canvasColor.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Text(
                      DateFormat.jm().format(now),
                      style: (theme.textTheme.bodySmall ?? const TextStyle())
                          .copyWith(
                            color: currentTimeColor ?? Colors.red,
                            fontSize: 10,
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

    return Stack(children: children);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final totalHeight = (maxHour - minHour + 1) * hourHeight;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: onGoToPreviousDay,
              ),
              Expanded(
                child: Text(
                  DateFormat.yMMMMEEEEd().format(date),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: onGoToNextDay,
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            child: SizedBox(
              height: totalHeight,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: timeLabelWidth,
                    height: totalHeight,
                    child: _buildTimeLabels(context),
                  ),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return Container(
                          height: totalHeight,
                          decoration: BoxDecoration(
                            border: Border(
                              left: BorderSide(
                                color: theme.dividerColor,
                                width: 0.5,
                              ),
                            ),
                          ),
                          child: _buildScheduleStack(
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
    );
  }
}
