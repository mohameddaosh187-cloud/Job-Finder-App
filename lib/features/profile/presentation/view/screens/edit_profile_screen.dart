import 'package:flutter/material.dart';

import 'package:job_finder/core/routes/theme/locale_controller.dart';

import '../../../data/profile_service.dart';

const Color _primaryBlue = Color(0xFF385CF2);

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final ProfileService _profileService = ProfileService();
  final TextEditingController _nameController = TextEditingController();

  bool _isSaving = false;

  bool get _isArabic =>
      LocaleController.instance.locale.languageCode == 'ar';

  String _text(String english, String arabic) {
    return _isArabic ? arabic : english;
  }

  @override
  void initState() {
    super.initState();

    _nameController.text = _profileService.userName == 'User'
        ? ''
        : _profileService.userName;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    final name = _nameController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _text(
              'Please enter your name.',
              'من فضلك أدخل اسمك.',
            ),
          ),
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await _profileService.updateName(name);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _text(
              'Profile updated successfully.',
              'تم تحديث الملف الشخصي بنجاح.',
            ),
          ),
        ),
      );

      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _text(
              'Failed to update profile: $error',
              'فشل تحديث الملف الشخصي: $error',
            ),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: LocaleController.instance,
      builder: (context, child) {
        final theme = Theme.of(context);
        final colors = theme.colorScheme;

        final backgroundColor = theme.scaffoldBackgroundColor;
        final surfaceColor = theme.cardColor;
        final textColor = colors.onSurface;
        final mutedColor = colors.onSurfaceVariant;
        final borderColor = theme.dividerColor;

        final avatarBackground = theme.brightness == Brightness.dark
            ? const Color(0xFF263755)
            : const Color(0xFFE3E9FF);

        return Directionality(
          textDirection:
              _isArabic ? TextDirection.rtl : TextDirection.ltr,
          child: Scaffold(
            backgroundColor: backgroundColor,
            appBar: AppBar(
              backgroundColor:
                  theme.appBarTheme.backgroundColor ?? backgroundColor,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              title: Text(
                _text('Edit profile', 'تعديل الملف الشخصي'),
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.w800,
                ),
              ),
              iconTheme: IconThemeData(
                color: textColor,
              ),
            ),
            body: SafeArea(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  const SizedBox(height: 12),
                  Center(
                    child: CircleAvatar(
                      radius: 42,
                      backgroundColor: avatarBackground,
                      child: const Icon(
                        Icons.person_outline_rounded,
                        color: _primaryBlue,
                        size: 42,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Text(
                    _text('Full name', 'الاسم بالكامل'),
                    style: TextStyle(
                      color: textColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _nameController,
                    textCapitalization: TextCapitalization.words,
                    keyboardType: TextInputType.name,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) {
                      if (!_isSaving) {
                        _saveProfile();
                      }
                    },
                    style: TextStyle(
                      color: textColor,
                    ),
                    decoration: InputDecoration(
                      hintText: _text(
                        'Enter your full name',
                        'أدخل اسمك بالكامل',
                      ),
                      hintStyle: TextStyle(
                        color: mutedColor,
                      ),
                      filled: true,
                      fillColor: surfaceColor,
                      prefixIcon: const Icon(
                        Icons.person_outline_rounded,
                        color: _primaryBlue,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                          color: borderColor,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                          color: borderColor,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                          color: _primaryBlue,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 26),
                  SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryBlue,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor:
                            _primaryBlue.withValues(alpha: 0.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              _text('Save changes', 'حفظ التغييرات'),
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
