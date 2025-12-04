import 'package:flutter/material.dart';
import 'assistant_page.dart';
import 'day_page.dart';
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
    required void Function(DateTime date) onOpenDayView,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: theme.colorScheme.surface),
            child: Center(
              child: Text(
                'O.P.A',
                style: TextStyle(
                  color: theme.colorScheme.onSurface,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.calendar_month),
            title: const Text('Calendar'),
            selected: currentRoute == 'calendar',
            onTap: () {
              Navigator.pop(context);
              if (currentRoute != 'calendar') {
                Navigator.of(context).popUntil((route) => route.isFirst);
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.assistant),
            title: const Text('Assistant'),
            selected: currentRoute == 'assistant',
            onTap: () {
              Navigator.pop(context);
              if (currentRoute != 'assistant') {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const AssistantPage(),
                  ),
                );
              }
            },
          ),
          if (currentRoute == 'calendar' || currentRoute == 'day') ...[
            const Divider(),
            ListTile(
              leading: const Icon(Icons.calendar_month_outlined),
              title: const Text('Month'),
              onTap: () {
                Navigator.pop(context);
                // If already on calendar:
                if (currentRoute == 'calendar') {
                  // If currently in week view, switch to month.
                  if (isWeekView) {
                    onViewSwitch?.call();
                  }
                  // If already in month view, do nothing (stay on page).
                } else {
                  // Not on calendar: go back to root (calendar).
                  Navigator.of(context).popUntil((route) => route.isFirst);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.view_week_outlined),
              title: const Text('Week'),
              onTap: () {
                Navigator.pop(context);
                // If already on calendar:
                if (currentRoute == 'calendar') {
                  // If currently in month view, switch to week.
                  if (!isWeekView) {
                    onViewSwitch?.call();
                  }
                  // If already in week view, do nothing.
                } else {
                  // Not on calendar: go to calendar (root) and request week view.
                  Navigator.of(context).popUntil((route) => route.isFirst);
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
                ),
                onTap: () {
                  Navigator.pop(context);
                  onToggleTheme!();
                },
              ),
          ],
        ],
      ),
    );
  }
}
