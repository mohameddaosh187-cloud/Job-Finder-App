import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:job_finder/core/routes/app_routes.dart';
import 'package:job_finder/core/routes/theme/locale_controller.dart';
import 'package:job_finder/features/auth/data/firebase/auth_service.dart';

import '../widgets/auth_header.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/primary_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  bool _obscurePassword = true;

  bool get _isArabic =>
      LocaleController.instance.locale.languageCode == 'ar';

  String _text(String english, String arabic) =>
      _isArabic ? arabic : english;

  @override
  void initState() {
    super.initState();
    LocaleController.instance.addListener(_onLocaleChanged);
  }

  @override
  void dispose() {
    LocaleController.instance.removeListener(_onLocaleChanged);
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLocaleChanged() {
    if (mounted) setState(() {});
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';

    if (email.isEmpty) {
      return _text(
        'Please enter your email address',
        'من فضلك أدخل البريد الإلكتروني',
      );
    }

    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      return _text(
        'Please enter a valid email address',
        'من فضلك أدخل بريدًا إلكترونيًا صحيحًا',
      );
    }

    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return _text(
        'Please enter your password',
        'من فضلك أدخل كلمة المرور',
      );
    }

    if (value.length < 6) {
      return _text(
        'Password must be at least 6 characters',
        'يجب ألا تقل كلمة المرور عن 6 أحرف',
      );
    }

    return null;
  }

  Future<void> _login() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final user = await _authService.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;

      final messenger = ScaffoldMessenger.of(context);

      Navigator.of(context).popUntil(
        (route) => route.isFirst,
      );

      messenger.showSnackBar(
        SnackBar(
          content: Text(
            _text(
              'Welcome back, ${user.email}!',
              'أهلًا بعودتك، ${user.email}!',
            ),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      String message;

      switch (e.code) {
        case 'invalid-credential':
        case 'wrong-password':
        case 'user-not-found':
          message = _text(
            'Invalid email or password.',
            'البريد الإلكتروني أو كلمة المرور غير صحيحة.',
          );
          break;

        case 'invalid-email':
          message = _text(
            'Please enter a valid email address.',
            'من فضلك أدخل بريدًا إلكترونيًا صحيحًا.',
          );
          break;

        case 'too-many-requests':
          message = _text(
            'Too many attempts. Please try again later.',
            'محاولات كثيرة. حاول مرة أخرى لاحقًا.',
          );
          break;

        case 'network-request-failed':
          message = _text(
            'Check your internet connection and try again.',
            'تحقق من اتصال الإنترنت وحاول مرة أخرى.',
          );
          break;

        default:
          message = _text(
            'Login failed. Please try again.',
            'فشل تسجيل الدخول. حاول مرة أخرى.',
          );
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
        ),
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
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _forgotPassword() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _text(
            'Password recovery will be added later.',
            'سيتم إضافة استعادة كلمة المرور لاحقًا.',
          ),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _openSignUp() {
    Navigator.pushNamed(
      context,
      AppRoutes.signup,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final background = theme.scaffoldBackgroundColor;
    final navy = colors.onSurface;
    final blue = colors.primary;
    final subtitle = colors.onSurfaceVariant;
    final borderColor = theme.dividerColor;
    final surfaceColor = theme.cardColor;

    return Directionality(
      textDirection: _isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: background,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 20,
            ),
            child: Center(
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
                        ),
                        color: navy,
                        style: IconButton.styleFrom(
                          backgroundColor: surfaceColor,
                          side: BorderSide(
                            color: borderColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),

                      AuthHeader(
                        title: _text(
                          'Welcome back!',
                          'أهلًا بعودتك!',
                        ),
                        subtitle: _text(
                          'Sign in to continue your job search and '
                              'discover new opportunities.',
                          'سجّل الدخول لمتابعة البحث عن وظيفة '
                              'واكتشاف فرص جديدة.',
                        ),
                        logoIcon: Icons.work_outline_rounded,
                      ),

                      const SizedBox(height: 34),

                      AuthTextField(
                        label: _text('Email address', 'البريد الإلكتروني'),
                        hint: _text(
                          'Enter your email address',
                          'أدخل بريدك الإلكتروني',
                        ),
                        icon: Icons.email_outlined,
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [
                          AutofillHints.email,
                        ],
                        validator: _validateEmail,
                      ),

                      const SizedBox(height: 22),

                      AuthTextField(
                        label: _text('Password', 'كلمة المرور'),
                        hint: _text(
                          'Enter your password',
                          'أدخل كلمة المرور',
                        ),
                        icon: Icons.lock_outline_rounded,
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        textInputAction: TextInputAction.done,
                        autofillHints: const [
                          AutofillHints.password,
                        ],
                        onFieldSubmitted: (_) => _login(),
                        onToggleVisibility: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                        validator: _validatePassword,
                      ),

                      const SizedBox(height: 10),

                      Align(
                        alignment: _isArabic
                            ? Alignment.centerLeft
                            : Alignment.centerRight,
                        child: TextButton(
                          onPressed: _forgotPassword,
                          style: TextButton.styleFrom(
                            foregroundColor: blue,
                            padding: EdgeInsets.zero,
                          ),
                          child: Text(
                            _text(
                              'Forgot password?',
                              'نسيت كلمة المرور؟',
                            ),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      PrimaryButton(
                        text: _isLoading
                            ? _text('Signing in...', 'جارٍ تسجيل الدخول...')
                            : _text('Log in', 'تسجيل الدخول'),
                        onPressed: _isLoading ? () {} : _login,
                      ),

                      const SizedBox(height: 28),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                            child: Text(
                              _text(
                                "Don't have an account?",
                                'ليس لديك حساب؟',
                              ),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: subtitle,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          TextButton(
                            onPressed: _openSignUp,
                            style: TextButton.styleFrom(
                              foregroundColor: blue,
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              _text('Sign up', 'إنشاء حساب'),
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
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
