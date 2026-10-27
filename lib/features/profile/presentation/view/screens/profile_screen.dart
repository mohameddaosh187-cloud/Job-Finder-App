import 'package:flutter/material.dart';

import 'package:job_finder/core/routes/theme/locale_controller.dart';

import '../../../data/profile_service.dart';
import '../widgets/profile_menu_tile.dart';
import 'edit_profile_screen.dart';
import 'job_preferences_screen.dart';
import 'notifications_screen.dart';
import 'saved_jobs_screen.dart';
import 'settings_screen.dart';

const Color _primaryBlue = Color(0xFF385CF2);

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ProfileService _profileService = ProfileService();

  bool _isUploadingPhoto = false;

  bool get _isArabic =>
      LocaleController.instance.locale.languageCode == 'ar';

  String _text(String english, String arabic) {
    return _isArabic ? arabic : english;
  }

  Future<void> _changeProfilePhoto() async {
    setState(() {
      _isUploadingPhoto = true;
    });

    try {
      final photoUrl =
          await _profileService.pickAndUploadProfilePhoto();

      if (!mounted) return;

      if (photoUrl != null) {
        setState(() {});

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _text(
                'Profile photo updated successfully',
                'تم تحديث الصورة الشخصية بنجاح',
              ),
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _text(
              'Could not update photo: $e',
              'تعذر تحديث الصورة: $e',
            ),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isUploadingPhoto = false;
        });
      }
    }
  }

  Future<void> _editProfile() async {
    final updated = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => const EditProfileScreen(),
      ),
    );

    if (updated == true && mounted) {
      setState(() {});
    }
  }

  Future<void> _openPage(Widget page) async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (context) => page,
      ),
    );

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _signOut() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(_text('Sign out', 'تسجيل الخروج')),
        content: Text(
          _text(
            'Are you sure you want to sign out?',
            'هل أنت متأكد أنك تريد تسجيل الخروج؟',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext, false);
            },
            child: Text(_text('Cancel', 'إلغاء')),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext, true);
            },
            child: Text(_text('Sign out', 'تسجيل الخروج')),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    try {
      await _profileService.signOut();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _text(
              'Could not sign out: $e',
              'تعذر تسجيل الخروج: $e',
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: LocaleController.instance,
      builder: (context, child) {
        final theme = Theme.of(context);
        final colors = theme.colorScheme;
        final isDark = theme.brightness == Brightness.dark;
        final isArabic = _isArabic;

        final userName = _profileService.userName;
        final userEmail = _profileService.userEmail;
        final photoUrl = _profileService.photoUrl;

        final backgroundColor = theme.scaffoldBackgroundColor;
        final surfaceColor = theme.cardColor;
        final textColor = colors.onSurface;
        final mutedColor = colors.onSurfaceVariant;
        final borderColor = theme.dividerColor;

        final avatarBackground = isDark
            ? const Color(0xFF263755)
            : const Color(0xFFE8EDFF);

        final signOutBorderColor = isDark
            ? const Color(0xFF59373D)
            : const Color(0xFFFFD5D5);

        return Directionality(
          textDirection:
              isArabic ? TextDirection.rtl : TextDirection.ltr,
          child: Scaffold(
            backgroundColor: backgroundColor,
            appBar: AppBar(
              backgroundColor: surfaceColor,
              foregroundColor: textColor,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              title: Text(
                _text('My Profile', 'ملفي الشخصي'),
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              actions: [
                IconButton(
                  onPressed: _editProfile,
                  tooltip: _text('Edit profile', 'تعديل الملف الشخصي'),
                  icon: const Icon(
                    Icons.edit_outlined,
                    color: _primaryBlue,
                  ),
                ),
                const SizedBox(width: 8),
              ],
            ),
            body: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: borderColor,
                    ),
                  ),
                  child: Column(
                    children: [
                      Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          CircleAvatar(
                            key: ValueKey(photoUrl),
                            radius: 48,
                            backgroundColor: avatarBackground,
                            backgroundImage:
                                photoUrl != null && photoUrl.isNotEmpty
                                    ? NetworkImage(photoUrl)
                                    : null,
                            child: photoUrl == null || photoUrl.isEmpty
                                ? Text(
                                    userName.isNotEmpty
                                        ? userName[0].toUpperCase()
                                        : 'U',
                                    style: const TextStyle(
                                      fontSize: 32,
                                      color: _primaryBlue,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                : null,
                          ),
                          Material(
                            color: _primaryBlue,
                            shape: const CircleBorder(),
                            child: InkWell(
                              onTap: _isUploadingPhoto
                                  ? null
                                  : _changeProfilePhoto,
                              customBorder: const CircleBorder(),
                              child: Padding(
                                padding: const EdgeInsets.all(9),
                                child: _isUploadingPhoto
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Icon(
                                        Icons.camera_alt_outlined,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text(
                        userName,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        userEmail,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: mutedColor,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 18),
                      OutlinedButton.icon(
                        onPressed: _editProfile,
                        icon: const Icon(Icons.edit_outlined),
                        label: Text(
                          _text('Edit Profile', 'تعديل الملف الشخصي'),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _primaryBlue,
                          side: const BorderSide(
                            color: _primaryBlue,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 26),
                Padding(
                  padding: const EdgeInsets.only(
                    left: 4,
                    bottom: 10,
                  ),
                  child: Text(
                    _text('Account', 'الحساب'),
                    style: TextStyle(
                      color: mutedColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                ProfileMenuTile(
                  icon: Icons.person_outline_rounded,
                  title: _text('Edit Profile', 'تعديل الملف الشخصي'),
                  subtitle: _text(
                    'Update your personal information',
                    'تحديث معلوماتك الشخصية',
                  ),
                  onTap: _editProfile,
                ),
                ProfileMenuTile(
                  icon: Icons.bookmark_outline_rounded,
                  title: _text('Saved Jobs', 'الوظائف المحفوظة'),
                  subtitle: _text(
                    'View and manage your bookmarked jobs',
                    'عرض وإدارة الوظائف التي حفظتها',
                  ),
                  onTap: () {
                    _openPage(
                      const SavedJobsScreen(
                        showBackButton: true,
                      ),
                    );
                  },
                ),
                ProfileMenuTile(
                  icon: Icons.tune_rounded,
                  title: _text('Job Preferences', 'تفضيلات الوظائف'),
                  subtitle: _text(
                    'Manage your preferred jobs',
                    'إدارة الوظائف التي تفضلها',
                  ),
                  onTap: () {
                    _openPage(const JobPreferencesScreen());
                  },
                ),
                ProfileMenuTile(
                  icon: Icons.notifications_none_rounded,
                  title: _text('Notifications', 'الإشعارات'),
                  subtitle: _text(
                    'Manage your notifications',
                    'إدارة الإشعارات',
                  ),
                  onTap: () {
                    _openPage(const NotificationsScreen());
                  },
                ),
                ProfileMenuTile(
                  icon: Icons.settings_outlined,
                  title: _text('Settings', 'الإعدادات'),
                  subtitle: _text(
                    'App preferences and options',
                    'تفضيلات التطبيق وخياراته',
                  ),
                  onTap: () {
                    _openPage(const SettingsScreen());
                  },
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 52,
                  child: OutlinedButton.icon(
                    onPressed: _signOut,
                    icon: const Icon(Icons.logout_rounded),
                    label: Text(_text('Sign Out', 'تسجيل الخروج')),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.redAccent,
                      side: BorderSide(
                        color: signOutBorderColor,
                      ),
                      backgroundColor: surfaceColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }
}
