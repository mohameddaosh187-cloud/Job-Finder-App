import 'package:flutter/material.dart';
import 'package:job_finder/core/routes/theme/locale_controller.dart';

class AuthHeader extends StatefulWidget {
  final String title;
  final String subtitle;
  final String logoText;
  final IconData? logoIcon;

  const AuthHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.logoText = 'JF',
    this.logoIcon,
  });

  static const Color blue = Color(0xFF385CF2);

  @override
  State<AuthHeader> createState() => _AuthHeaderState();
}

class _AuthHeaderState extends State<AuthHeader> {
  bool get _isArabic =>
      LocaleController.instance.locale.languageCode == 'ar';

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
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final titleColor = colors.onSurface;
    final subtitleTextColor = colors.onSurfaceVariant;

    return Directionality(
      textDirection: _isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AuthHeader.blue,
                  borderRadius: BorderRadius.circular(15),
                ),
                alignment: Alignment.center,
                child: widget.logoIcon != null
                    ? Icon(
                        widget.logoIcon,
                        color: Colors.white,
                        size: 27,
                      )
                    : Text(
                        widget.logoText,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
              const SizedBox(width: 12),
              const Text(
                'JobFinder',
                textDirection: TextDirection.ltr,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          Text(
            widget.title,
            textAlign: _isArabic ? TextAlign.right : TextAlign.left,
            style: TextStyle(
              color: titleColor,
              fontSize: 29,
              fontWeight: FontWeight.bold,
              letterSpacing: _isArabic ? 0 : -0.5,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            widget.subtitle,
            textAlign: _isArabic ? TextAlign.right : TextAlign.left,
            style: TextStyle(
              color: subtitleTextColor,
              fontSize: 14,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
