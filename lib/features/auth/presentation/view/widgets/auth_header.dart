import 'package:flutter/material.dart';

class AuthHeader extends StatelessWidget {
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

  static const Color navy = Color(0xFF17243D);
  static const Color blue = Color(0xFF385CF2);
  static const Color subtitleColor = Color(0xFF6B7891);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: blue,
                borderRadius: BorderRadius.circular(15),
              ),
              alignment: Alignment.center,
              child: logoIcon != null
                  ? Icon(logoIcon, color: Colors.white, size: 27)
                  : Text(
                      logoText,
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
              style: TextStyle(
                color: navy,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 30),
        Text(
          title,
          style: const TextStyle(
            color: navy,
            fontSize: 29,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          subtitle,
          style: const TextStyle(
            color: subtitleColor,
            fontSize: 14,
            height: 1.6,
          ),
        ),
      ],
    );
  }
}
