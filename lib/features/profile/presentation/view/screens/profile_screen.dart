import 'package:flutter/material.dart';

import '../../../data/profile_service.dart';
import 'edit_profile_screen.dart';

const Color _primaryBlue = Color(0xFF385CF2);
const Color _pageBackground = Color(0xFFF6F8FC);
const Color _textDark = Color(0xFF172033);
const Color _textMuted = Color(0xFF7B8497);
const Color _borderColor = Color(0xFFE5EAF3);

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ProfileService _profileService = ProfileService();

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

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _confirmLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Log out'),
          content: const Text('Are you sure you want to log out?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Log out'),
            ),
          ],
        );
      },
    );

    if (!mounted || shouldLogout != true) {
      return;
    }

    try {
      await _profileService.signOut();

      if (!mounted) {
        return;
      }

      Navigator.of(context).pushNamedAndRemoveUntil(
        '/login',
        (route) => false,
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Logout failed: $error'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _profileService.currentUser;
    final name = _profileService.userName;
    final email = _profileService.userEmail;
    final photoUrl = _profileService.photoUrl;

    final initials = name.trim().isEmpty
        ? 'U'
        : name
            .trim()
            .split(RegExp(r'\s+'))
            .take(2)
            .map((part) => part[0].toUpperCase())
            .join();

    final profileStrength = [
      name.isNotEmpty && name != 'User',
      email.isNotEmpty,
      photoUrl != null && photoUrl.isNotEmpty,
    ].where((value) => value).length;

    final strengthPercent = (profileStrength / 3 * 100).round();

    return Scaffold(
      backgroundColor: _pageBackground,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'My profile',
                    style: TextStyle(
                      color: _textDark,
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: _editProfile,
                  child: const Text(
                    'Edit',
                    style: TextStyle(
                      color: _primaryBlue,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: const Color(0xFFE3E9FF),
                  backgroundImage:
                      photoUrl != null && photoUrl.isNotEmpty
                          ? NetworkImage(photoUrl)
                          : null,
                  child: photoUrl == null || photoUrl.isEmpty
                      ? Text(
                          initials,
                          style: const TextStyle(
                            color: _primaryBlue,
                            fontSize: 19,
                            fontWeight: FontWeight.w800,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: _textDark,
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        email,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: _textMuted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: _borderColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Profile strength',
                          style: TextStyle(
                            color: _textDark,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Text(
                        '$strengthPercent%',
                        style: const TextStyle(
                          color: _primaryBlue,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 13),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: LinearProgressIndicator(
                      value: strengthPercent / 100,
                      minHeight: 7,
                      backgroundColor: const Color(0xFFE3E8F2),
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(_primaryBlue),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Complete your profile to stand out to employers.',
                    style: TextStyle(
                      color: _textMuted,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            const _SectionTitle(title: 'ACCOUNT'),
            const SizedBox(height: 12),

            _ProfileMenuTile(
              icon: Icons.description_outlined,
              title: 'Resume & portfolio',
              subtitle: 'Manage your documents',
              onTap: () => _showMessage(
                'Resume & portfolio will be available soon.',
              ),
            ),
            _ProfileMenuTile(
              icon: Icons.tune_rounded,
              title: 'Job preferences',
              subtitle: 'Role, location, salary',
              onTap: () => _showMessage(
                'Job preferences will be available soon.',
              ),
            ),
            _ProfileMenuTile(
              icon: Icons.notifications_none_rounded,
              title: 'Notifications',
              subtitle: 'Alerts for new opportunities',
              onTap: () => _showMessage(
                'Notification settings will be available soon.',
              ),
            ),
            _ProfileMenuTile(
              icon: Icons.settings_outlined,
              title: 'Settings & privacy',
              subtitle: 'Security and account',
              onTap: () => _showMessage(
                'Settings & privacy will be available soon.',
              ),
            ),

            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _borderColor),
              ),
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(
                  Icons.logout_rounded,
                  color: Colors.redAccent,
                ),
                title: const Text(
                  'Log out',
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                onTap: _confirmLogout,
              ),
            ),

            if (user == null) ...[
              const SizedBox(height: 12),
              const Text(
                'You are currently signed out.',
                textAlign: TextAlign.center,
                style: TextStyle(color: _textMuted),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: _textMuted,
        fontSize: 11,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.1,
      ),
    );
  }
}

class _ProfileMenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ProfileMenuTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: _borderColor),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 5,
        ),
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: const Color(0xFFEDF0FF),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: _primaryBlue,
            size: 21,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: _textDark,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            color: _textMuted,
            fontSize: 10,
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right_rounded,
          color: _textMuted,
        ),
        onTap: onTap,
      ),
    );
  }
}
