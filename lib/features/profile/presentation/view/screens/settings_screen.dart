import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:job_finder/core/theme/theme_controller.dart';
import 'package:job_finder/core/theme/locale_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

const Color _primaryBlue = Color(0xFF385CF2);

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _biometricLogin = false;
  bool _privateProfile = false;
  bool _loading = true;
  bool _changingLanguage = false;

  bool get _isArabic => LocaleController.instance.locale.languageCode == 'ar';

  String _text(String english, String arabic) {
    return _isArabic ? arabic : english;
  }

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      if (!mounted) return;

      setState(() {
        _biometricLogin = prefs.getBool('settings_biometric_login') ?? false;
        _privateProfile = prefs.getBool('settings_private_profile') ?? false;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _loading = false;
      });

      _showMessage(_text('Could not load settings.', 'تعذر تحميل الإعدادات.'));
    }
  }

  Future<void> _saveSetting(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  Future<void> _changeSetting(
    String key,
    bool value,
    void Function(bool) updateState,
  ) async {
    final previousValue = key == 'settings_biometric_login'
        ? _biometricLogin
        : _privateProfile;

    setState(() {
      updateState(value);
    });

    try {
      await _saveSetting(key, value);
    } catch (_) {
      if (!mounted) return;

      setState(() {
        updateState(previousValue);
      });

      _showMessage(
        _text('Could not save this setting.', 'تعذر حفظ هذا الإعداد.'),
      );
    }
  }

  Future<void> _changeLanguage(String languageCode) async {
    if (_changingLanguage) return;

    if (LocaleController.instance.locale.languageCode == languageCode) {
      return;
    }

    setState(() {
      _changingLanguage = true;
    });

    try {
      await LocaleController.instance.setLocale(Locale(languageCode));
    } catch (_) {
      if (mounted) {
        _showMessage(
          _text(
            'Could not change language. Please try again.',
            'تعذر تغيير اللغة. حاول مرة أخرى.',
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _changingLanguage = false;
        });
      }
    }
  }

  Future<void> _showLanguageDialog() async {
    String selectedLanguage = LocaleController.instance.locale.languageCode;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              title: Text(_text('Choose language', 'اختر اللغة')),
              content: RadioGroup<String>(
                groupValue: selectedLanguage,
                onChanged: (String? value) {
                  if (value == null || _changingLanguage) return;

                  setDialogState(() {
                    selectedLanguage = value;
                  });
                },
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    RadioListTile<String>(
                      value: 'en',
                      title: Text('English'),
                      secondary: Text('🇬🇧'),
                      activeColor: _primaryBlue,
                    ),
                    RadioListTile<String>(
                      value: 'ar',
                      title: Text('العربية'),
                      secondary: Text('🇪🇬'),
                      activeColor: _primaryBlue,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                  },
                  child: Text(_text('Cancel', 'إلغاء')),
                ),
                ElevatedButton(
                  onPressed: _changingLanguage
                      ? null
                      : () {
                          Navigator.of(dialogContext).pop();
                          _changeLanguage(selectedLanguage);
                        },
                  child: Text(_text('Save', 'حفظ')),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _changePassword() async {
    final email = FirebaseAuth.instance.currentUser?.email;

    if (email == null || email.isEmpty) {
      _showMessage(
        _text(
          'No email address found for your account.',
          'لم يتم العثور على بريد إلكتروني لحسابك.',
        ),
      );
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

      if (!mounted) return;

      _showMessage(
        _text(
          'Password reset email sent to $email',
          'تم إرسال رابط إعادة تعيين كلمة المرور إلى $email',
        ),
      );
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;

      _showMessage(
        error.message ??
            _text(
              'Could not send password reset email.',
              'تعذر إرسال بريد إعادة تعيين كلمة المرور.',
            ),
      );
    } catch (_) {
      if (!mounted) return;

      _showMessage(
        _text(
          'Something went wrong. Please try again.',
          'حدث خطأ. حاول مرة أخرى.',
        ),
      );
    }
  }

  Future<void> _confirmDeleteAccount() async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(_text('Account security', 'أمان الحساب')),
        content: Text(
          _text(
            'Account deletion is not enabled here. '
                'Contact the app administrator if you need your account deleted.',
            'حذف الحساب غير متاح هنا. '
                'تواصل مع مسؤول التطبيق إذا كنت تريد حذف حسابك.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
            },
            child: Text(_text('Close', 'إغلاق')),
          ),
        ],
      ),
    );
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        ThemeController.instance,
        LocaleController.instance,
      ]),
      builder: (context, child) {
        final isDark = ThemeController.instance.isDarkMode;
        final isArabic = _isArabic;

        final pageBackground = isDark
            ? const Color(0xFF10131A)
            : const Color(0xFFF6F8FC);

        final surfaceColor = isDark ? const Color(0xFF1B202B) : Colors.white;

        final textColor = isDark
            ? const Color(0xFFF3F5F9)
            : const Color(0xFF172033);

        final mutedColor = isDark
            ? const Color(0xFFAAB4C5)
            : const Color(0xFF7B8497);

        final borderColor = isDark
            ? const Color(0xFF303847)
            : const Color(0xFFE5EAF3);

        return Directionality(
          textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
          child: Scaffold(
            backgroundColor: pageBackground,
            appBar: AppBar(
              title: Text(
                _text('Settings & Privacy', 'الإعدادات والخصوصية'),
                style: TextStyle(color: textColor, fontWeight: FontWeight.w700),
              ),
              backgroundColor: pageBackground,
              foregroundColor: textColor,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
            ),
            body: _loading
                ? const Center(
                    child: CircularProgressIndicator(color: _primaryBlue),
                  )
                : ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      Text(
                        _text('APPEARANCE', 'المظهر'),
                        style: TextStyle(
                          color: mutedColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          letterSpacing: isArabic ? 0 : 1,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        decoration: BoxDecoration(
                          color: surfaceColor,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: borderColor),
                        ),
                        child: Column(
                          children: [
                            SwitchListTile(
                              secondary: Icon(
                                isDark
                                    ? Icons.dark_mode_rounded
                                    : Icons.light_mode_rounded,
                                color: _primaryBlue,
                              ),
                              title: Text(
                                _text('Dark Mode', 'الوضع الداكن'),
                                style: TextStyle(
                                  color: textColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              subtitle: Text(
                                isDark
                                    ? _text(
                                        'Dark mode is enabled',
                                        'الوضع الداكن مفعّل',
                                      )
                                    : _text(
                                        'Light mode is enabled',
                                        'الوضع الفاتح مفعّل',
                                      ),
                                style: TextStyle(color: mutedColor),
                              ),
                              value: isDark,
                              activeTrackColor: _primaryBlue,
                              onChanged: (value) async {
                                try {
                                  await ThemeController.instance.toggleTheme(
                                    value,
                                  );
                                } catch (_) {
                                  if (!context.mounted) return;

                                  _showMessage(
                                    _text(
                                      'Could not save theme preference',
                                      'تعذر حفظ إعدادات المظهر',
                                    ),
                                  );
                                }
                              },
                            ),
                            Divider(
                              height: 1,
                              indent: 16,
                              endIndent: 16,
                              color: borderColor,
                            ),
                            ListTile(
                              leading: const Icon(
                                Icons.language_rounded,
                                color: _primaryBlue,
                              ),
                              title: Text(
                                _text('Language', 'اللغة'),
                                style: TextStyle(
                                  color: textColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              subtitle: Text(
                                isArabic ? 'العربية' : 'English',
                                style: TextStyle(color: mutedColor),
                              ),
                              trailing: _changingLanguage
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: _primaryBlue,
                                      ),
                                    )
                                  : Icon(
                                      Icons.chevron_right_rounded,
                                      color: mutedColor,
                                    ),
                              onTap: _changingLanguage
                                  ? null
                                  : _showLanguageDialog,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        _text('ACCOUNT SECURITY', 'أمان الحساب'),
                        style: TextStyle(
                          color: mutedColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          letterSpacing: isArabic ? 0 : 1,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        decoration: BoxDecoration(
                          color: surfaceColor,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: borderColor),
                        ),
                        child: Column(
                          children: [
                            ListTile(
                              leading: const Icon(
                                Icons.lock_outline_rounded,
                                color: _primaryBlue,
                              ),
                              title: Text(
                                _text('Change password', 'تغيير كلمة المرور'),
                                style: TextStyle(color: textColor),
                              ),
                              subtitle: Text(
                                _text(
                                  'Receive a password reset email',
                                  'استلام بريد لإعادة تعيين كلمة المرور',
                                ),
                                style: TextStyle(color: mutedColor),
                              ),
                              trailing: Icon(
                                Icons.chevron_right_rounded,
                                color: mutedColor,
                              ),
                              onTap: _changePassword,
                            ),
                            Divider(
                              height: 1,
                              indent: 16,
                              endIndent: 16,
                              color: borderColor,
                            ),
                            SwitchListTile(
                              secondary: const Icon(
                                Icons.fingerprint_rounded,
                                color: _primaryBlue,
                              ),
                              title: Text(
                                _text(
                                  'Biometric login',
                                  'تسجيل الدخول بالبصمة',
                                ),
                                style: TextStyle(color: textColor),
                              ),
                              subtitle: Text(
                                _text(
                                  'Preference only; biometric authentication '
                                      'is not implemented yet',
                                  'هذا إعداد تفضيلي فقط؛ '
                                      'ميزة التحقق بالبصمة غير مفعّلة حاليًا',
                                ),
                                style: TextStyle(color: mutedColor),
                              ),
                              value: _biometricLogin,
                              activeTrackColor: _primaryBlue,
                              onChanged: (value) => _changeSetting(
                                'settings_biometric_login',
                                value,
                                (v) => _biometricLogin = v,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        _text('PRIVACY', 'الخصوصية'),
                        style: TextStyle(
                          color: mutedColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          letterSpacing: isArabic ? 0 : 1,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        decoration: BoxDecoration(
                          color: surfaceColor,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: borderColor),
                        ),
                        child: Column(
                          children: [
                            SwitchListTile(
                              secondary: const Icon(
                                Icons.visibility_outlined,
                                color: _primaryBlue,
                              ),
                              title: Text(
                                _text('Private profile', 'الملف الشخصي الخاص'),
                                style: TextStyle(color: textColor),
                              ),
                              subtitle: Text(
                                _text(
                                  'Save your preference on this device',
                                  'حفظ تفضيلاتك على هذا الجهاز',
                                ),
                                style: TextStyle(color: mutedColor),
                              ),
                              value: _privateProfile,
                              activeTrackColor: _primaryBlue,
                              onChanged: (value) => _changeSetting(
                                'settings_private_profile',
                                value,
                                (v) => _privateProfile = v,
                              ),
                            ),
                            Divider(
                              height: 1,
                              indent: 16,
                              endIndent: 16,
                              color: borderColor,
                            ),
                            ListTile(
                              leading: const Icon(
                                Icons.delete_outline_rounded,
                                color: Colors.redAccent,
                              ),
                              title: Text(
                                _text('Account deletion', 'حذف الحساب'),
                                style: const TextStyle(color: Colors.redAccent),
                              ),
                              subtitle: Text(
                                _text(
                                  'Account deletion is not available '
                                      'in this screen',
                                  'حذف الحساب غير متاح من هذه الشاشة',
                                ),
                                style: TextStyle(color: mutedColor),
                              ),
                              trailing: Icon(
                                Icons.chevron_right_rounded,
                                color: mutedColor,
                              ),
                              onTap: _confirmDeleteAccount,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        _text(
                          'Some settings are stored locally and do not change '
                              'server-side account permissions.',
                          'يتم حفظ بعض الإعدادات على الجهاز فقط، '
                              'ولا تغيّر صلاحيات الحساب على الخادم.',
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
