import 'package:flutter/material.dart';

import '../../../data/profile_service.dart';
import '../widgets/profile_menu_tile.dart';
import 'edit_profile_screen.dart';
import 'job_preferences_screen.dart';
import 'notifications_screen.dart';
import 'saved_jobs_screen.dart';
import 'settings_screen.dart';

const Color _primaryBlue = Color(0xFF385CF2);
const Color _pageBackground = Color(0xFFF6F8FC);
const Color _textDark = Color(0xFF172033);
const Color _textMuted = Color(0xFF7B8497);

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ProfileService _profileService = ProfileService();

  bool _isUploadingPhoto = false;

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
          const SnackBar(
            content: Text('Profile photo updated successfully'),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not update photo: $e'),
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
        title: const Text('Sign out'),
        content: const Text(
          'Are you sure you want to sign out?',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext, false);
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext, true);
            },
            child: const Text('Sign out'),
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
          content: Text('Could not sign out: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final userName = _profileService.userName;
    final userEmail = _profileService.userEmail;
    final photoUrl = _profileService.photoUrl;

    return Scaffold(
      backgroundColor: _pageBackground,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'My Profile',
          style: TextStyle(
            color: _textDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _editProfile,
            tooltip: 'Edit profile',
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
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      key: ValueKey(photoUrl),
                      radius: 48,
                      backgroundColor: const Color(0xFFE8EDFF),
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
                  style: const TextStyle(
                    color: _textDark,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  userEmail,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: _textMuted,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 18),
                OutlinedButton.icon(
                  onPressed: _editProfile,
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Edit Profile'),
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
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 10),
            child: Text(
              'Account',
              style: TextStyle(
                color: _textMuted,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ProfileMenuTile(
            icon: Icons.person_outline_rounded,
            title: 'Edit Profile',
            subtitle: 'Update your personal information',
            onTap: _editProfile,
          ),
          ProfileMenuTile(
            icon: Icons.bookmark_outline_rounded,
            title: 'Saved Jobs',
            subtitle: 'View and manage your bookmarked jobs',
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
            title: 'Job Preferences',
            subtitle: 'Manage your preferred jobs',
            onTap: () {
              _openPage(const JobPreferencesScreen());
            },
          ),
          ProfileMenuTile(
            icon: Icons.notifications_none_rounded,
            title: 'Notifications',
            subtitle: 'Manage your notifications',
            onTap: () {
              _openPage(const NotificationsScreen());
            },
          ),
          ProfileMenuTile(
            icon: Icons.settings_outlined,
            title: 'Settings',
            subtitle: 'App preferences and options',
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
              label: const Text('Sign Out'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.redAccent,
                side: const BorderSide(
                  color: Color(0xFFFFD5D5),
                ),
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}