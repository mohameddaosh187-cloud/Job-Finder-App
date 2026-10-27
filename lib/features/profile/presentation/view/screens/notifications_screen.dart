import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const Color _primaryBlue = Color(0xFF385CF2);
const Color _pageBackground = Color(0xFFF6F8FC);
const Color _textDark = Color(0xFF172033);
const Color _textMuted = Color(0xFF7B8497);
const Color _borderColor = Color(0xFFE5EAF3);

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _jobAlerts = true;
  bool _applicationUpdates = true;
  bool _recommendations = false;
  bool _newsAndTips = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();

    if (!mounted) return;

    setState(() {
      _jobAlerts = prefs.getBool('notification_job_alerts') ?? true;
      _applicationUpdates =
          prefs.getBool('notification_application_updates') ?? true;
      _recommendations =
          prefs.getBool('notification_recommendations') ?? false;
      _newsAndTips = prefs.getBool('notification_news_tips') ?? false;
      _loading = false;
    });
  }

  Future<void> _savePreference(String key, bool value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(key, value);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Notification preference saved'),
          duration: Duration(seconds: 1),
        ),
      );
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not save your preference'),
        ),
      );
    }
  }

  Future<void> _changePreference(
    String key,
    bool value,
    void Function(bool) updateState,
  ) async {
    setState(() {
      updateState(value);
    });

    await _savePreference(key, value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _pageBackground,
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(
            color: _textDark,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: _pageBackground,
        foregroundColor: _textDark,
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const Text(
                  'NOTIFICATION PREFERENCES',
                  style: TextStyle(
                    color: _textMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: _borderColor),
                  ),
                  child: Column(
                    children: [
                      _NotificationTile(
                        icon: Icons.work_outline_rounded,
                        title: 'Job alerts',
                        subtitle: 'Get notified about new job opportunities',
                        value: _jobAlerts,
                        onChanged: (value) => _changePreference(
                          'notification_job_alerts',
                          value,
                          (v) => _jobAlerts = v,
                        ),
                      ),
                      const Divider(height: 1, indent: 16, endIndent: 16),
                      _NotificationTile(
                        icon: Icons.assignment_outlined,
                        title: 'Application updates',
                        subtitle: 'Updates about your job applications',
                        value: _applicationUpdates,
                        onChanged: (value) => _changePreference(
                          'notification_application_updates',
                          value,
                          (v) => _applicationUpdates = v,
                        ),
                      ),
                      const Divider(height: 1, indent: 16, endIndent: 16),
                      _NotificationTile(
                        icon: Icons.recommend_outlined,
                        title: 'Job recommendations',
                        subtitle: 'Suggestions based on your preferences',
                        value: _recommendations,
                        onChanged: (value) => _changePreference(
                          'notification_recommendations',
                          value,
                          (v) => _recommendations = v,
                        ),
                      ),
                      const Divider(height: 1, indent: 16, endIndent: 16),
                      _NotificationTile(
                        icon: Icons.lightbulb_outline_rounded,
                        title: 'Career news and tips',
                        subtitle: 'Helpful career advice and news',
                        value: _newsAndTips,
                        onChanged: (value) => _changePreference(
                          'notification_news_tips',
                          value,
                          (v) => _newsAndTips = v,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Your choices are saved on this device. These settings '
                  'control your preferences; actual push notifications '
                  'require notification delivery to be configured.',
                  style: TextStyle(
                    color: _textMuted,
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
              ],
            ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _NotificationTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFEDF0FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: _primaryBlue),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: _textDark,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: _textMuted,
                    fontSize: 11,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            activeTrackColor: _primaryBlue,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
