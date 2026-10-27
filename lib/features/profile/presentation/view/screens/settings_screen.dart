import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

const Color _primaryBlue = Color(0xFF385CF2);
const Color _pageBackground = Color(0xFFF6F8FC);
const Color _textDark = Color(0xFF172033);
const Color _textMuted = Color(0xFF7B8497);
const Color _borderColor = Color(0xFFE5EAF3);

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _biometricLogin = false;
  bool _privateProfile = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    if (!mounted) return;

    setState(() {
      _biometricLogin = prefs.getBool('settings_biometric_login') ?? false;
      _privateProfile = prefs.getBool('settings_private_profile') ?? false;
      _loading = false;
    });
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
    setState(() {
      updateState(value);
    });

    try {
      await _saveSetting(key, value);
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not save this setting')),
      );
    }
  }

  Future<void> _changePassword() async {
    final email = FirebaseAuth.instance.currentUser?.email;

    if (email == null || email.isEmpty) {
      _showMessage('No email address found for your account.');
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

      if (!mounted) return;

      _showMessage('Password reset email sent to $email');
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;

      _showMessage(error.message ?? 'Could not send password reset email.');
    } catch (_) {
      if (!mounted) return;

      _showMessage('Something went wrong. Please try again.');
    }
  }

  Future<void> _confirmDeleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Account security'),
        content: const Text(
          'Account deletion is not enabled here. '
          'Contact the app administrator if you need your account deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Close'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      _showMessage('No changes were made to your account.');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _pageBackground,
      appBar: AppBar(
        title: const Text(
          'Settings & Privacy',
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
                  'ACCOUNT SECURITY',
                  style: TextStyle(
                    color: _textMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: _borderColor),
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(
                          Icons.lock_outline_rounded,
                          color: _primaryBlue,
                        ),
                        title: const Text('Change password'),
                        subtitle: const Text(
                          'Receive a password reset email',
                        ),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: _changePassword,
                      ),
                      const Divider(height: 1, indent: 16, endIndent: 16),
                      SwitchListTile(
                        secondary: const Icon(
                          Icons.fingerprint_rounded,
                          color: _primaryBlue,
                        ),
                        title: const Text('Biometric login'),
                        subtitle: const Text(
                          'Preference only; biometric authentication '
                          'is not implemented yet',
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
                const Text(
                  'PRIVACY',
                  style: TextStyle(
                    color: _textMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: _borderColor),
                  ),
                  child: Column(
                    children: [
                      SwitchListTile(
                        secondary: const Icon(
                          Icons.visibility_outlined,
                          color: _primaryBlue,
                        ),
                        title: const Text('Private profile'),
                        subtitle: const Text(
                          'Save your preference on this device',
                        ),
                        value: _privateProfile,
                        activeTrackColor: _primaryBlue,
                        onChanged: (value) => _changeSetting(
                          'settings_private_profile',
                          value,
                          (v) => _privateProfile = v,
                        ),
                      ),
                      const Divider(height: 1, indent: 16, endIndent: 16),
                      ListTile(
                        leading: const Icon(
                          Icons.delete_outline_rounded,
                          color: Colors.redAccent,
                        ),
                        title: const Text(
                          'Account deletion',
                          style: TextStyle(color: Colors.redAccent),
                        ),
                        subtitle: const Text(
                          'Account deletion is not available in this screen',
                        ),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: _confirmDeleteAccount,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Some settings are stored locally and do not change '
                  'server-side account permissions.',
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
