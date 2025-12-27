import 'package:flutter/material.dart';
import 'assistant_page.dart';
import 'database_helper.dart';

class AppDrawer extends StatelessWidget {
  final String currentRoute;
  final VoidCallback? onViewSwitch;
  final bool isWeekView;
  final VoidCallback? onToggleTheme;
  final ThemeMode? themeMode;
  final DateTime? selectedDate;
  final List<Event> events;
  final double hourHeight;
  final int minHour;
  final int maxHour;
  final double timeLabelWidth;
  final Function(Event)? onEventTapped;
  final Function(DateTime)? onOpenDayView;
  final VoidCallback? onCloseDayView;

  const AppDrawer({
    super.key,
    required this.currentRoute,
    this.onViewSwitch,
    this.isWeekView = false,
    this.onToggleTheme,
    this.themeMode,
    this.selectedDate,
    this.events = const [],
    this.hourHeight = 60.0,
    this.minHour = 0,
    this.maxHour = 23,
    this.timeLabelWidth = 50.0,
    this.onEventTapped,
    this.onOpenDayView,
    this.onCloseDayView,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Drawer(
      width: 220,
      child: ListTileTheme(
        data: ListTileThemeData(
          dense: true,
          minLeadingWidth: 20,
          horizontalTitleGap: 8,
          contentPadding: EdgeInsets.symmetric(horizontal: 12),
        ),
        child: Column(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: theme.colorScheme.surface),
              margin: EdgeInsets.zero,
              padding: const EdgeInsets.symmetric(
                vertical: 12.0,
                horizontal: 8.0,
              ),
              child: Center(
                child: Text(
                  'O.P.A',
                  style: TextStyle(
                    color: theme.colorScheme.onSurface,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.calendar_month),
              title: Text(
                'Calendar',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              selected: currentRoute == 'calendar',
              onTap: () {
                Navigator.pop(context);
                // Ensure root is visible
                Navigator.of(context).popUntil((route) => route.isFirst);
                // Close Day view if open
                onCloseDayView?.call();
                // If we happen to be in week view, switch to month
                if (isWeekView) onViewSwitch?.call();
              },
            ),
            ListTile(
              leading: const Icon(Icons.assistant),
              title: Text(
                'Assistant',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              selected: currentRoute == 'assistant',
              onTap: () {
                Navigator.pop(context);
                if (currentRoute != 'assistant') {
                  // Ensure the calendar (root) is visible before pushing assistant so navigation is consistent
                  Navigator.of(context).popUntil((route) => route.isFirst);
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => AssistantPage(
                        initialSelectedDate: selectedDate,
                        onOpenDayView: onOpenDayView,
                        onViewSwitch: onViewSwitch,
                        isWeekView: isWeekView,
                        onCloseDayView: onCloseDayView,
                        onToggleTheme: onToggleTheme,
                        themeMode: themeMode,
                      ),
                    ),
                  );
                }
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: Text(
                'Day',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                final DateTime dayToOpen = selectedDate ?? DateTime.now();
                // Ensure root is visible and close any Day view, then request embedded Day view
                Navigator.of(context).popUntil((route) => route.isFirst);
                onCloseDayView?.call();
                onOpenDayView?.call(dayToOpen);
              },
            ),

            ListTile(
              leading: const Icon(Icons.calendar_month_outlined),
              title: Text(
                'Month',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                // Ensure root and close day view
                Navigator.of(context).popUntil((route) => route.isFirst);
                onCloseDayView?.call();
                // If currently in week view, switch to month.
                if (isWeekView) {
                  onViewSwitch?.call();
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.view_week_outlined),
              title: Text(
                'Week',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                // Ensure root and close day view
                Navigator.of(context).popUntil((route) => route.isFirst);
                onCloseDayView?.call();
                // If currently in month view, switch to week.
                if (!isWeekView) {
                  onViewSwitch?.call();
                }
              },
            ),
            if (onToggleTheme != null && themeMode != null)
              ListTile(
                leading: Icon(
                  themeMode == ThemeMode.light
                      ? Icons.dark_mode_outlined
                      : Icons.light_mode_outlined,
                ),
                title: Text(
                  themeMode == ThemeMode.light ? 'Dark Mode' : 'Light Mode',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  onToggleTheme!();
                },
              ),
          ],
        ),
      ),
    );
  }
}
