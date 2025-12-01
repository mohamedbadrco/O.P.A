import 'package:flutter/material.dart';
import 'assistant_page.dart';

class AppDrawer extends StatelessWidget {
  final String currentRoute;
  final VoidCallback? onViewSwitch;
  final bool isWeekView;

  const AppDrawer({
    super.key,
    required this.currentRoute,
    this.onViewSwitch,
    this.isWeekView = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
            ),
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
              Navigator.pop(context); // Close drawer
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
              Navigator.pop(context); // Close drawer
              if (currentRoute != 'assistant') {
                Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (context) => const AssistantPage()),
                );
              }
            },
          ),
          if (currentRoute == 'calendar' && onViewSwitch != null) ...[
             const Divider(),
             ListTile(
              leading: Icon(isWeekView ? Icons.calendar_month_outlined : Icons.view_week_outlined),
              title: Text(isWeekView ? 'Switch to Month View' : 'Switch to Week View'),
              onTap: () {
                Navigator.pop(context); // Close drawer
                onViewSwitch!();
              },
             ),
          ],
        ],
      ),
    );
  }
}
