import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:job_finder/core/theme/locale_controller.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:job_finder/features/auth/presentation/view_model/auth_cubit.dart';
import 'package:job_finder/features/auth/presentation/view_model/auth_state.dart';

import '../widgets/auth_header.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/primary_button.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  static const Color blueColor = Color(0xFF385CF2);

  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();


  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptTerms = false;
  bool get _isLoading => context.watch<AuthCubit>().state.status == AuthStatus.loading;

  bool get _isArabic => LocaleController.instance.locale.languageCode == 'ar';

  String _text(String english, String arabic) {
    return _isArabic ? arabic : english;
  }

  @override
  void initState() {
    super.initState();
    LocaleController.instance.addListener(_onLocaleChanged);
  }

  @override
  void dispose() {
    LocaleController.instance.removeListener(_onLocaleChanged);

    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();

    super.dispose();
  }

  void _onLocaleChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return _text('Please enter your full name', 'من فضلك أدخل اسمك بالكامل');
    }

    if (value.trim().length < 3) {
      return _text(
        'Name must be at least 3 characters',
        'يجب ألا يقل الاسم عن 3 أحرف',
      );
    }

    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return _text('Please enter your email', 'من فضلك أدخل بريدك الإلكتروني');
    }

    final emailRegex = RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]+$');

    if (!emailRegex.hasMatch(value.trim())) {
      return _text(
        'Please enter a valid email',
        'من فضلك أدخل بريدًا إلكترونيًا صحيحًا',
      );
    }

    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return _text('Please enter a password', 'من فضلك أدخل كلمة المرور');
    }

    if (value.length < 8) {
      return _text(
        'Password must be at least 8 characters',
        'يجب ألا تقل كلمة المرور عن 8 أحرف',
      );
    }

    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return _text('Please confirm your password', 'من فضلك أكد كلمة المرور');
    }

    if (value != _passwordController.text) {
      return _text('Passwords do not match', 'كلمتا المرور غير متطابقتين');
    }

    return null;
  }

  Future<void> _createAccount() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _text(
              'Please accept the Terms and Conditions',
              'من فضلك وافق على الشروط والأحكام وسياسة الخصوصية',
            ),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    try {
      final user = await context.read<AuthCubit>().signUp(
        fullName: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;

      final messenger = ScaffoldMessenger.of(context);

      Navigator.of(
        context,
        rootNavigator: true,
      ).popUntil((route) => route.isFirst);

      messenger.showSnackBar(
        SnackBar(
          content: Text(
            _text(
              'Welcome, ${user.fullName}! Account created.',
              'أهلًا ${user.fullName}! تم إنشاء حسابك بنجاح.',
            ),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      String message;

      switch (e.code) {
        case 'email-already-in-use':
          message = _text(
            'This email is already registered.',
            'هذا البريد الإلكتروني مسجل بالفعل.',
          );
          break;

        case 'weak-password':
          message = _text(
            'Please choose a stronger password.',
            'من فضلك اختر كلمة مرور أقوى.',
          );
          break;

        case 'invalid-email':
          message = _text(
            'Please enter a valid email address.',
            'من فضلك أدخل بريدًا إلكترونيًا صحيحًا.',
          );
          break;

        case 'network-request-failed':
          message = _text(
            'Check your internet connection and try again.',
            'تحقق من اتصال الإنترنت وحاول مرة أخرى.',
          );
          break;

        case 'operation-not-allowed':
          message = _text(
            'Email and password registration is disabled.',
            'إنشاء الحساب بالبريد الإلكتروني وكلمة المرور غير مفعّل.',
          );
          break;

        default:
          message = _text(
            'Could not create account. Please try again.',
            'تعذر إنشاء الحساب. حاول مرة أخرى.',
          );
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
      );
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _text(
              'Something went wrong. Please try again.',
              'حدث خطأ ما. حاول مرة أخرى.',
            ),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final backgroundColor = theme.scaffoldBackgroundColor;
    final textColor = colors.onSurface;
    final subtitleColor = colors.onSurfaceVariant;
    final surfaceColor = theme.cardColor;
    final borderColor = theme.dividerColor;

    return Directionality(
      textDirection: _isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: backgroundColor,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 430),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.of(context).maybePop();
                        },
                        icon: Icon(
                          _isArabic
                              ? Icons.arrow_forward_rounded
                              : Icons.arrow_back_rounded,
                          color: textColor,
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor: surfaceColor,
                          side: BorderSide(color: borderColor),
                        ),
                      ),

                      const SizedBox(height: 25),

                      AuthHeader(
                        title: _text('Create your account', 'أنشئ حسابك'),
                        subtitle: _text(
                          'Start your journey to a career you love.',
                          'ابدأ رحلتك نحو الوظيفة التي تحلم بها.',
                        ),
                      ),

                      const SizedBox(height: 30),

                      AuthTextField(
                        label: _text('Full name', 'الاسم بالكامل'),
                        hint: _text(
                          'Enter your full name',
                          'أدخل اسمك بالكامل',
                        ),
                        icon: Icons.person_outline_rounded,
                        controller: _nameController,
                        keyboardType: TextInputType.name,
                        textCapitalization: TextCapitalization.words,
                        validator: _validateName,
                      ),

                      const SizedBox(height: 20),

                      AuthTextField(
                        label: _text('Email address', 'البريد الإلكتروني'),
                        hint: _text('you@example.com', 'you@example.com'),
                        icon: Icons.mail_outline_rounded,
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        autocorrect: false,
                        validator: _validateEmail,
                      ),

                      const SizedBox(height: 20),

                      AuthTextField(
                        label: _text('Password', 'كلمة المرور'),
                        hint: _text(
                          'At least 8 characters',
                          '8 أحرف على الأقل',
                        ),
                        icon: Icons.lock_outline_rounded,
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        validator: _validatePassword,
                        onToggleVisibility: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),

                      const SizedBox(height: 20),

                      AuthTextField(
                        label: _text('Confirm password', 'تأكيد كلمة المرور'),
                        hint: _text(
                          'Re-enter your password',
                          'أعد إدخال كلمة المرور',
                        ),
                        icon: Icons.lock_outline_rounded,
                        controller: _confirmPasswordController,
                        obscureText: _obscureConfirmPassword,
                        textInputAction: TextInputAction.done,
                        validator: _validateConfirmPassword,
                        onFieldSubmitted: (_) => _createAccount(),
                        onToggleVisibility: () {
                          setState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          });
                        },
                      ),

                      const SizedBox(height: 14),

                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 24,
                            height: 24,
                            child: Checkbox(
                              value: _acceptTerms,
                              activeColor: blueColor,
                              side: BorderSide(color: subtitleColor),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                              onChanged: (value) {
                                setState(() {
                                  _acceptTerms = value ?? false;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 3),
                              child: Text(
                                _text(
                                  'I agree to the Terms and Conditions and '
                                      'Privacy Policy.',
                                  'أوافق على الشروط والأحكام وسياسة الخصوصية.',
                                ),
                                style: TextStyle(
                                  color: subtitleColor,
                                  fontSize: 13,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 25),

                      PrimaryButton(
                        text: _isLoading
                            ? _text(
                                'Creating account...',
                                'جارٍ إنشاء الحساب...',
                              )
                            : _text('Create account', 'إنشاء حساب'),
                        icon: _isArabic
                            ? Icons.arrow_back_rounded
                            : Icons.arrow_forward_rounded,
                        height: 56,
                        onPressed: _isLoading ? () {} : _createAccount,
                      ),

                      const SizedBox(height: 25),

                      Center(
                        child: Wrap(
                          alignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              _text(
                                'Already have an account?',
                                'لديك حساب بالفعل؟',
                              ),
                              style: TextStyle(
                                color: subtitleColor,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(width: 6),
                            GestureDetector(
                              onTap: () {
                                Navigator.of(context).maybePop();
                              },
                              child: Text(
                                _text('Log in', 'تسجيل الدخول'),
                                style: const TextStyle(
                                  color: blueColor,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 15),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
