import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const Color _primaryBlue = Color(0xFF385CF2);
const Color _pageBackground = Color(0xFFF6F8FC);
const Color _textDark = Color(0xFF172033);
const Color _textMuted = Color(0xFF7B8497);
const Color _borderColor = Color(0xFFE5EAF3);

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
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not load your preferences.'),
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

      await prefs.setString('profile_job_type', _jobType);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Job preferences saved successfully.'),
        ),
      );

      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to save job preferences.'),
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
    return Scaffold(
      backgroundColor: _pageBackground,
      appBar: AppBar(
        backgroundColor: _pageBackground,
        elevation: 0,
        iconTheme: const IconThemeData(color: _textDark),
        title: const Text(
          'Job preferences',
          style: TextStyle(
            color: _textDark,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    const Text(
                      'Find the right opportunity',
                      style: TextStyle(
                        color: _textDark,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Set your preferences to focus on jobs that match your goals.',
                      style: TextStyle(
                        color: _textMuted,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 28),

                    _fieldLabel('Desired job title'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _jobTitleController,
                      textCapitalization: TextCapitalization.words,
                      decoration: _inputDecoration(
                        hint: 'e.g. Flutter Developer',
                        icon: Icons.work_outline_rounded,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your desired job title.';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 22),
                    _fieldLabel('Preferred location'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _locationController,
                      textCapitalization: TextCapitalization.words,
                      decoration: _inputDecoration(
                        hint: 'e.g. Cairo or Remote',
                        icon: Icons.location_on_outlined,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your preferred location.';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 22),
                    _fieldLabel('Expected salary'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _salaryController,
                      keyboardType: TextInputType.number,
                      decoration: _inputDecoration(
                        hint: 'e.g. 15000 EGP',
                        icon: Icons.payments_outlined,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your expected salary.';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 22),
                    _fieldLabel('Employment type'),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: _jobType,
                      decoration: _inputDecoration(
                        hint: 'Choose employment type',
                        icon: Icons.schedule_rounded,
                      ),
                      items: _jobTypes.map((type) {
                        return DropdownMenuItem<String>(
                          value: type,
                          child: Text(type),
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
                        onPressed: _isSaving ? null : _savePreferences,
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
                            : const Text(
                                'Save preferences',
                                style: TextStyle(
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
  }

  Widget _fieldLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        color: _textDark,
        fontSize: 14,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: _textMuted,
        fontSize: 13,
      ),
      prefixIcon: Icon(icon, color: _primaryBlue),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: _primaryBlue,
          width: 1.5,
        ),
      ),
    );
  }
}
