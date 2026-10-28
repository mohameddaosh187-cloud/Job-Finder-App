import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:job_finder/core/routes/theme/locale_controller.dart';

const Color _primaryBlue = Color(0xFF385CF2);

class JobPreferencesScreen extends StatefulWidget {
  const JobPreferencesScreen({super.key});

  @override
  State<JobPreferencesScreen> createState() =>
      _JobPreferencesScreenState();
}

class _JobPreferencesScreenState extends State<JobPreferencesScreen> {
  final _formKey = GlobalKey<FormState>();

  final _jobTitleController = TextEditingController();
  final _locationController = TextEditingController();
  final _salaryController = TextEditingController();

  String _jobType = 'Full-time';
  bool _isLoading = true;
  bool _isSaving = false;

  final List<String> _jobTypes = [
    'Full-time',
    'Part-time',
    'Remote',
    'Contract',
    'Internship',
  ];

  bool get _isArabic =>
      LocaleController.instance.locale.languageCode == 'ar';

  String _text(String english, String arabic) {
    return _isArabic ? arabic : english;
  }

  String _jobTypeLabel(String type) {
    switch (type) {
      case 'Full-time':
        return _text('Full-time', 'دوام كامل');
      case 'Part-time':
        return _text('Part-time', 'دوام جزئي');
      case 'Remote':
        return _text('Remote', 'عن بُعد');
      case 'Contract':
        return _text('Contract', 'عقد عمل');
      case 'Internship':
        return _text('Internship', 'تدريب');
      default:
        return type;
    }
  }

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      _jobTitleController.text =
          prefs.getString('profile_job_title') ?? '';

      _locationController.text =
          prefs.getString('profile_job_location') ?? '';

      _salaryController.text =
          prefs.getString('profile_expected_salary') ?? '';

      final savedJobType = prefs.getString('profile_job_type');

      if (savedJobType != null && _jobTypes.contains(savedJobType)) {
        _jobType = savedJobType;
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _text(
                'Could not load your preferences.',
                'تعذر تحميل تفضيلاتك.',
              ),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _savePreferences() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setString(
        'profile_job_title',
        _jobTitleController.text.trim(),
      );

      await prefs.setString(
        'profile_job_location',
        _locationController.text.trim(),
      );

      await prefs.setString(
        'profile_expected_salary',
        _salaryController.text.trim(),
      );

      await prefs.setString(
        'profile_job_type',
        _jobType,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _text(
              'Job preferences saved successfully.',
              'تم حفظ تفضيلات الوظائف بنجاح.',
            ),
          ),
        ),
      );

      Navigator.of(context).pop(true);
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _text(
              'Failed to save job preferences.',
              'فشل حفظ تفضيلات الوظائف.',
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
  void dispose() {
    _jobTitleController.dispose();
    _locationController.dispose();
    _salaryController.dispose();
    super.dispose();
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
        final primaryColor = colors.primary;

        return Directionality(
          textDirection:
              _isArabic ? TextDirection.rtl : TextDirection.ltr,
          child: Scaffold(
            backgroundColor: pageBackground,
            appBar: AppBar(
              backgroundColor:
                  theme.appBarTheme.backgroundColor ?? pageBackground,
              foregroundColor: textColor,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              title: Text(
                _text('Job preferences', 'تفضيلات الوظائف'),
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            body: _isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      color: primaryColor,
                    ),
                  )
                : SafeArea(
                    child: Form(
                      key: _formKey,
                      child: ListView(
                        padding: const EdgeInsets.all(20),
                        children: [
                          Text(
                            _text(
                              'Find the right opportunity',
                              'اعثر على الفرصة المناسبة',
                            ),
                            style: TextStyle(
                              color: textColor,
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _text(
                              'Set your preferences to focus on jobs '
                              'that match your goals.',
                              'حدد تفضيلاتك للتركيز على الوظائف '
                              'التي تتناسب مع أهدافك.',
                            ),
                            style: TextStyle(
                              color: mutedColor,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 28),
                          _fieldLabel(
                            _text(
                              'Desired job title',
                              'المسمى الوظيفي المطلوب',
                            ),
                            textColor,
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _jobTitleController,
                            textCapitalization: TextCapitalization.words,
                            style: TextStyle(color: textColor),
                            decoration: _inputDecoration(
                              hint: _text(
                                'e.g. Flutter Developer',
                                'مثال: مطور Flutter',
                              ),
                              icon: Icons.work_outline_rounded,
                              textColor: textColor,
                              mutedColor: mutedColor,
                              surfaceColor: surfaceColor,
                              borderColor: borderColor,
                              primaryColor: primaryColor,
                            ),
                            validator: (value) {
                              if (value == null ||
                                  value.trim().isEmpty) {
                                return _text(
                                  'Please enter your desired job title.',
                                  'من فضلك أدخل المسمى الوظيفي المطلوب.',
                                );
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 22),
                          _fieldLabel(
                            _text(
                              'Preferred location',
                              'الموقع المفضل',
                            ),
                            textColor,
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _locationController,
                            textCapitalization: TextCapitalization.words,
                            style: TextStyle(color: textColor),
                            decoration: _inputDecoration(
                              hint: _text(
                                'e.g. Cairo or Remote',
                                'مثال: القاهرة أو عن بُعد',
                              ),
                              icon: Icons.location_on_outlined,
                              textColor: textColor,
                              mutedColor: mutedColor,
                              surfaceColor: surfaceColor,
                              borderColor: borderColor,
                              primaryColor: primaryColor,
                            ),
                            validator: (value) {
                              if (value == null ||
                                  value.trim().isEmpty) {
                                return _text(
                                  'Please enter your preferred location.',
                                  'من فضلك أدخل الموقع المفضل.',
                                );
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 22),
                          _fieldLabel(
                            _text(
                              'Expected salary',
                              'الراتب المتوقع',
                            ),
                            textColor,
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _salaryController,
                            keyboardType: TextInputType.number,
                            style: TextStyle(color: textColor),
                            decoration: _inputDecoration(
                              hint: _text(
                                'e.g. 15000 EGP',
                                'مثال: 15000 جنيه',
                              ),
                              icon: Icons.payments_outlined,
                              textColor: textColor,
                              mutedColor: mutedColor,
                              surfaceColor: surfaceColor,
                              borderColor: borderColor,
                              primaryColor: primaryColor,
                            ),
                            validator: (value) {
                              if (value == null ||
                                  value.trim().isEmpty) {
                                return _text(
                                  'Please enter your expected salary.',
                                  'من فضلك أدخل الراتب المتوقع.',
                                );
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 22),
                          _fieldLabel(
                            _text(
                              'Employment type',
                              'نوع التوظيف',
                            ),
                            textColor,
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            initialValue: _jobType,
                            isExpanded: true,
                            dropdownColor: surfaceColor,
                            style: TextStyle(
                              color: textColor,
                              fontSize: 14,
                            ),
                            iconEnabledColor: mutedColor,
                            decoration: _inputDecoration(
                              hint: _text(
                                'Choose employment type',
                                'اختر نوع التوظيف',
                              ),
                              icon: Icons.schedule_rounded,
                              textColor: textColor,
                              mutedColor: mutedColor,
                              surfaceColor: surfaceColor,
                              borderColor: borderColor,
                              primaryColor: primaryColor,
                            ),
                            items: _jobTypes.map((type) {
                              return DropdownMenuItem<String>(
                                value: type,
                                child: Text(
                                  _jobTypeLabel(type),
                                  style: TextStyle(
                                    color: textColor,
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  _jobType = value;
                                });
                              }
                            },
                          ),
                          const SizedBox(height: 32),
                          SizedBox(
                            height: 52,
                            child: ElevatedButton(
                              onPressed: _isSaving
                                  ? null
                                  : _savePreferences,
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
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Text(
                                      _text(
                                        'Save preferences',
                                        'حفظ التفضيلات',
                                      ),
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
          ),
        );
      },
    );
  }

  Widget _fieldLabel(
    String label,
    Color textColor,
  ) {
    return Text(
      label,
      style: TextStyle(
        color: textColor,
        fontSize: 14,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
    required Color textColor,
    required Color mutedColor,
    required Color surfaceColor,
    required Color borderColor,
    required Color primaryColor,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: mutedColor,
        fontSize: 13,
      ),
      prefixIcon: Icon(
        icon,
        color: primaryColor,
      ),
      filled: true,
      fillColor: surfaceColor,
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
        borderSide: BorderSide(
          color: primaryColor,
          width: 1.5,
        ),
      ),
      errorStyle: const TextStyle(
        color: Colors.redAccent,
        fontSize: 12,
      ),
    );
  }
}
