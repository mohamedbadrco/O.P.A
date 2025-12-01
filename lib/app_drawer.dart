import 'package:flutter/material.dart';
import 'assistant_page.dart';

class AppDrawer extends StatelessWidget {
  final String currentRoute;

  const AppDrawer({super.key, required this.currentRoute});

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
        ],
      ),
    );
  }
}
