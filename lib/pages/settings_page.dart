import 'package:flutter/material.dart';
import '../widgets/slide_in_widget.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          // 모바일 터치 최적화: 최소 높이 56dp, 더 큰 패딩
          // 스크롤 애니메이션 적용
          SlideInWidget(
            index: 0,
            child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 8,
              ),
              leading: const Icon(
                Icons.notifications_outlined,
                size: 28,
              ),
              title: const Text(
                'Notifications',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: const Text(
                'Manage your alerts',
                style: TextStyle(fontSize: 14),
              ),
              trailing: Switch(
                value: true,
                onChanged: (value) {
                  // TODO: Implement notification logic
                },
              ),
              minVerticalPadding: 12,
            ),
            ),
          ),
          const SizedBox(height: 8),
          SlideInWidget(
            index: 1,
            child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 8,
              ),
              leading: const Icon(
                Icons.info_outline,
                size: 28,
              ),
              title: const Text(
                'About',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: const Text(
                'App information',
                style: TextStyle(fontSize: 14),
              ),
              trailing: const Icon(Icons.chevron_right, size: 28),
              minVerticalPadding: 12,
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Random Pomodoro Timer'),
                    content: const Text(
                      'Random Pomodoro Timer\n\n'
                      'Version 1.0.0\n\n'
                      'An app to help you maintain focus with random timer sessions.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Close'),
                      ),
                    ],
                  ),
                );
              },
            ),
            ),
          ),
          const SizedBox(height: 8),
          SlideInWidget(
            index: 2,
            child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 8,
              ),
              leading: const Icon(
                Icons.help_outline,
                size: 28,
              ),
              title: const Text(
                'Help',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: const Text(
                'How to use the app',
                style: TextStyle(fontSize: 14),
              ),
              trailing: const Icon(Icons.chevron_right, size: 28),
              minVerticalPadding: 12,
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('How to Use'),
                    content: const Text(
                      '1. Spin the wheel to choose your study time\n'
                      '2. Complete your focus session\n'
                      '3. Take a break\n'
                      '4. Repeat and stay motivated!\n\n'
                      'You have 2 attempts per day.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Got it'),
                      ),
                    ],
                  ),
                );
              },
            ),
            ),
          ),
        ],
      ),
    );
  }
}

