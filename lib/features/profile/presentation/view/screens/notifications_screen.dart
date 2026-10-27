import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:job_finder/core/routes/theme/locale_controller.dart';

const Color _primaryBlue = Color(0xFF385CF2);

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _jobAlerts = true;
  bool _applicationUpdates = true;
  bool _recommendations = false;
  bool _newsAndTips = false;
  bool _loading = true;

  bool get _isArabic =>
      LocaleController.instance.locale.languageCode == 'ar';

  String _text(String english, String arabic) {
    return _isArabic ? arabic : english;
  }

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      if (!mounted) return;

      setState(() {
        _jobAlerts =
            prefs.getBool('notification_job_alerts') ?? true;
        _applicationUpdates =
            prefs.getBool('notification_application_updates') ?? true;
        _recommendations =
            prefs.getBool('notification_recommendations') ?? false;
        _newsAndTips =
            prefs.getBool('notification_news_tips') ?? false;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _loading = false;
      });

      _showMessage(
        _text(
          'Could not load notification preferences',
          'تعذر تحميل إعدادات الإشعارات',
        ),
      );
    }
  }

  Future<void> _savePreference(String key, bool value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(key, value);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _text(
              'Notification preference saved',
              'تم حفظ إعدادات الإشعارات',
            ),
          ),
          duration: const Duration(seconds: 1),
        ),
      );
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _text(
              'Could not save your preference',
              'تعذر حفظ الإعدادات',
            ),
          ),
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

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: LocaleController.instance,
      builder: (context, child) {
        final theme = Theme.of(context);
        final colors = theme.colorScheme;

        final pageBackground = theme.scaffoldBackgroundColor;
        final surfaceColor = theme.cardColor;
        final textColor = colors.onSurface;
        final mutedColor = colors.onSurfaceVariant;
        final borderColor = theme.dividerColor;

        return Directionality(
          textDirection:
              _isArabic ? TextDirection.rtl : TextDirection.ltr,
          child: Scaffold(
            backgroundColor: pageBackground,
            appBar: AppBar(
              title: Text(
                _text('Notifications', 'الإشعارات'),
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
              backgroundColor:
                  theme.appBarTheme.backgroundColor ?? pageBackground,
              foregroundColor: textColor,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
            ),
            body: _loading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: _primaryBlue,
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      Text(
                        _text(
                          'NOTIFICATION PREFERENCES',
                          'تفضيلات الإشعارات',
                        ),
                        style: TextStyle(
                          color: mutedColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          letterSpacing: _isArabic ? 0 : 1,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Container(
                        decoration: BoxDecoration(
                          color: surfaceColor,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: borderColor,
                          ),
                        ),
                        child: Column(
                          children: [
                            _NotificationTile(
                              icon: Icons.work_outline_rounded,
                              title: _text(
                                'Job alerts',
                                'تنبيهات الوظائف',
                              ),
                              subtitle: _text(
                                'Get notified about new job opportunities',
                                'احصل على إشعارات بفرص العمل الجديدة',
                              ),
                              value: _jobAlerts,
                              onChanged: (value) => _changePreference(
                                'notification_job_alerts',
                                value,
                                (v) => _jobAlerts = v,
                              ),
                            ),
                            Divider(
                              height: 1,
                              indent: 16,
                              endIndent: 16,
                              color: borderColor,
                            ),
                            _NotificationTile(
                              icon: Icons.assignment_outlined,
                              title: _text(
                                'Application updates',
                                'تحديثات طلبات التوظيف',
                              ),
                              subtitle: _text(
                                'Updates about your job applications',
                                'تابع التحديثات المتعلقة بطلبات التوظيف',
                              ),
                              value: _applicationUpdates,
                              onChanged: (value) => _changePreference(
                                'notification_application_updates',
                                value,
                                (v) => _applicationUpdates = v,
                              ),
                            ),
                            Divider(
                              height: 1,
                              indent: 16,
                              endIndent: 16,
                              color: borderColor,
                            ),
                            _NotificationTile(
                              icon: Icons.recommend_outlined,
                              title: _text(
                                'Job recommendations',
                                'ترشيحات الوظائف',
                              ),
                              subtitle: _text(
                                'Suggestions based on your preferences',
                                'اقتراحات بناءً على تفضيلاتك',
                              ),
                              value: _recommendations,
                              onChanged: (value) => _changePreference(
                                'notification_recommendations',
                                value,
                                (v) => _recommendations = v,
                              ),
                            ),
                            Divider(
                              height: 1,
                              indent: 16,
                              endIndent: 16,
                              color: borderColor,
                            ),
                            _NotificationTile(
                              icon: Icons.lightbulb_outline_rounded,
                              title: _text(
                                'Career news and tips',
                                'أخبار ونصائح مهنية',
                              ),
                              subtitle: _text(
                                'Helpful career advice and news',
                                'نصائح مهنية وأخبار مفيدة',
                              ),
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
                      Text(
                        _text(
                          'Your choices are saved on this device. These settings '
                          'control your preferences; actual push notifications '
                          'require notification delivery to be configured.',
                          'يتم حفظ اختياراتك على هذا الجهاز. تتحكم هذه الإعدادات '
                          'في تفضيلاتك، أما إشعارات الدفع الفعلية فتتطلب '
                          'إعداد خدمة إرسال الإشعارات.',
                        ),
                        style: TextStyle(
                          color: mutedColor,
                          fontSize: 12,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
          ),
        );
      },
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
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final iconBackground = isDark
        ? const Color(0xFF263755)
        : const Color(0xFFEDF0FF);

    final mutedColor = colors.onSurfaceVariant;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 10,
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: iconBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: _primaryBlue,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: colors.onSurface,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: mutedColor,
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
