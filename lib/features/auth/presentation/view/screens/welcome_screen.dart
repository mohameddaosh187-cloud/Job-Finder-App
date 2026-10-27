import 'package:flutter/material.dart';

import 'package:job_finder/core/routes/app_routes.dart';
import 'package:job_finder/core/routes/theme/locale_controller.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  static const Color blue = Color(0xFF385CF2);
  static const Color orange = Color(0xFFF59C3D);

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
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
    super.dispose();
  }

  void _onLocaleChanged() {
    if (mounted) setState(() {});
  }

  void _openLogin() {
    Navigator.pushNamed(context, AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final background = theme.scaffoldBackgroundColor;
    final navy = colors.onSurface;
    final subtitle = colors.onSurfaceVariant;
    final surfaceColor = theme.cardColor;

    final lightBlue = isDark
        ? const Color(0xFF202B43)
        : const Color(0xFFE3EBFF);

    final laptopScreenColor = isDark
        ? const Color(0xFF0D111B)
        : const Color(0xFF17243D);

    final laptopDisplayColor = isDark
        ? const Color(0xFF252D3D)
        : Colors.white;

    final searchFieldColor = isDark
        ? const Color(0xFF35405A)
        : const Color(0xFFE3EBFF);

    final illustrationLineColor = isDark
        ? const Color(0xFF424B5D)
        : const Color(0xFFE0E5F0);

    return Directionality(
      textDirection: _isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: background,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Center(
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: SizedBox(
                    width: 390,
                    height: 844,
                    child: Stack(
                      children: [
                        Positioned(
                          left: 24,
                          top: 82,
                          child: Container(
                            width: 342,
                            height: 310,
                            decoration: BoxDecoration(
                              color: lightBlue,
                              borderRadius: BorderRadius.circular(28),
                            ),
                          ),
                        ),
                        Positioned(
                          left: 70,
                          top: 126,
                          child: Container(
                            width: 250,
                            height: 194,
                            decoration: BoxDecoration(
                              color: surfaceColor,
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                        ),
                        Positioned(
                          left: 104,
                          top: 151,
                          child: Container(
                            width: 182,
                            height: 112,
                            decoration: BoxDecoration(
                              color: laptopScreenColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        Positioned(
                          left: 116,
                          top: 164,
                          child: Container(
                            width: 158,
                            height: 86,
                            decoration: BoxDecoration(
                              color: laptopDisplayColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                        Positioned(
                          left: 128,
                          top: 179,
                          child: Container(
                            width: 104,
                            height: 17,
                            decoration: BoxDecoration(
                              color: searchFieldColor,
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                        ),
                        Positioned(
                          left: 128,
                          top: 207,
                          child: _line(
                            130,
                            9,
                            illustrationLineColor,
                          ),
                        ),
                        Positioned(
                          left: 128,
                          top: 225,
                          child: _line(
                            95,
                            9,
                            illustrationLineColor,
                          ),
                        ),
                        Positioned(
                          left: 153,
                          top: 276,
                          child: Container(
                            width: 82,
                            height: 46,
                            decoration: BoxDecoration(
                              color: WelcomeScreen.blue,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        Positioned(
                          left: 174,
                          top: 267,
                          child: Container(
                            width: 40,
                            height: 16,
                            decoration: BoxDecoration(
                              color: WelcomeScreen.blue,
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                        ),
                        Positioned(
                          left: 285,
                          top: 117,
                          child: Container(
                            width: 42,
                            height: 42,
                            alignment: Alignment.center,
                            decoration: const BoxDecoration(
                              color: WelcomeScreen.orange,
                              shape: BoxShape.circle,
                            ),
                            child: const Text(
                              'JF',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                        // Main heading
                        Positioned(
                          left: 26,
                          top: 420,
                          width: 340,
                          child: Text(
                            _text(
                              'Your next chapter\nstarts here.',
                              'خطوتك القادمة\nتبدأ من هنا.',
                            ),
                            textAlign:
                                _isArabic ? TextAlign.right : TextAlign.left,
                            style: TextStyle(
                              color: navy,
                              fontSize: _isArabic ? 27 : 29,
                              height: 1.2,
                              fontWeight: FontWeight.bold,
                              letterSpacing: _isArabic ? 0 : -0.4,
                            ),
                          ),
                        ),

                        // Subtitle
                        Positioned(
                          left: 26,
                          top: 506,
                          width: 335,
                          child: Text(
                            _text(
                              'Discover roles that match your skills, goals,\n'
                                  'and the way you want to work.',
                              'اكتشف وظائف تناسب مهاراتك وأهدافك،\n'
                                  'وطريقة العمل التي تفضلها.',
                            ),
                            textAlign:
                                _isArabic ? TextAlign.right : TextAlign.left,
                            style: TextStyle(
                              color: subtitle,
                              fontSize: _isArabic ? 12 : 12,
                              height: 1.5,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ),

                        // Feature chips
                        Positioned(
                          left: 27,
                          top: 570,
                          child: _chip(
                            width: 112,
                            text: _text('Curated jobs', 'وظائف مختارة'),
                            backgroundColor: surfaceColor,
                            textColor: WelcomeScreen.blue,
                          ),
                        ),
                        Positioned(
                          left: 149,
                          top: 570,
                          child: _chip(
                            width: 116,
                            text: _text('Career growth', 'تطور مهني'),
                            backgroundColor: surfaceColor,
                            textColor: WelcomeScreen.blue,
                          ),
                        ),

                        // Get started button
                        Positioned(
                          left: 24,
                          top: 640,
                          child: SizedBox(
                            width: 342,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _openLogin,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: WelcomeScreen.blue,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: EdgeInsets.zero,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: Text(
                                _text('Get started', 'ابدأ الآن'),
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Login link
                        Positioned(
                          left: 24,
                          top: 716,
                          width: 342,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Flexible(
                                child: Text(
                                  _text(
                                    'Already have an account?',
                                    'لديك حساب بالفعل؟',
                                  ),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: subtitle,
                                    fontSize: _isArabic ? 11 : 11,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 5),
                              GestureDetector(
                                onTap: _openLogin,
                                child: Text(
                                  _text('Log in', 'تسجيل الدخول'),
                                  style: const TextStyle(
                                    color: WelcomeScreen.blue,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  static Widget _line(
    double width,
    double height,
    Color color,
  ) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(5),
      ),
    );
  }

  static Widget _chip({
    required double width,
    required String text,
    required Color backgroundColor,
    required Color textColor,
  }) {
    return Container(
      width: width,
      height: 30,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: textColor,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
