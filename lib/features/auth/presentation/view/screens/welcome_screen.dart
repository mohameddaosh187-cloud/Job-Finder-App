import 'package:flutter/material.dart';

import 'package:job_finder/core/routes/app_routes.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  static const Color background = Color(0xFFF6F8FC);
  static const Color navy = Color(0xFF17243D);
  static const Color blue = Color(0xFF385CF2);
  static const Color lightBlue = Color(0xFFE3EBFF);
  static const Color subtitle = Color(0xFF6B7891);
  static const Color orange = Color(0xFFF59C3D);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Center(
            child: FittedBox(
              fit: BoxFit.contain,
              child: SizedBox(
                width: 390,
                height: 844,
                child: Stack(
                  children: [
                    // Hero illustration panel
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

                    // White illustration card
                    Positioned(
                      left: 70,
                      top: 126,
                      child: Container(
                        width: 250,
                        height: 194,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                    ),

                    // Laptop screen
                    Positioned(
                      left: 104,
                      top: 151,
                      child: Container(
                        width: 182,
                        height: 112,
                        decoration: BoxDecoration(
                          color: navy,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),

                    // Laptop display
                    Positioned(
                      left: 116,
                      top: 164,
                      child: Container(
                        width: 158,
                        height: 86,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),

                    // Search field illustration
                    Positioned(
                      left: 128,
                      top: 179,
                      child: Container(
                        width: 104,
                        height: 17,
                        decoration: BoxDecoration(
                          color: lightBlue,
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ),

                    // Job result lines
                    Positioned(left: 128, top: 207, child: _line(130, 9)),
                    Positioned(left: 128, top: 225, child: _line(95, 9)),

                    // Briefcase body
                    Positioned(
                      left: 153,
                      top: 276,
                      child: Container(
                        width: 82,
                        height: 46,
                        decoration: BoxDecoration(
                          color: blue,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),

                    // Briefcase handle
                    Positioned(
                      left: 174,
                      top: 267,
                      child: Container(
                        width: 40,
                        height: 16,
                        decoration: BoxDecoration(
                          color: blue,
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ),

                    // Orange JF badge
                    Positioned(
                      left: 285,
                      top: 117,
                      child: Container(
                        width: 42,
                        height: 42,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                          color: orange,
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

                    // Heading
                    const Positioned(
                      left: 26,
                      top: 420,
                      width: 340,
                      child: Text(
                        'Your next chapter\nstarts here.',
                        style: TextStyle(
                          color: navy,
                          fontSize: 29,
                          height: 1.2,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.4,
                        ),
                      ),
                    ),

                    // Description
                    const Positioned(
                      left: 26,
                      top: 506,
                      width: 335,
                      child: Text(
                        'Discover roles that match your skills, goals,\n'
                        'and the way you want to work.',
                        style: TextStyle(
                          color: subtitle,
                          fontSize: 12,
                          height: 1.5,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),

                    // Curated jobs chip
                    Positioned(
                      left: 27,
                      top: 570,
                      child: _chip(width: 112, text: 'Curated jobs'),
                    ),

                    // Career growth chip
                    Positioned(
                      left: 149,
                      top: 570,
                      child: _chip(width: 116, text: 'Career growth'),
                    ),

                    // Get started button
                    Positioned(
                      left: 24,
                      top: 640,
                      child: SizedBox(
                        width: 342,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, AppRoutes.login);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: blue,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text(
                            'Get started',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Login prompt
                    Positioned(
                      left: 24,
                      top: 716,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Already have an account?  ',
                            style: TextStyle(
                              color: subtitle,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(context, AppRoutes.login);
                            },
                            child: const Text(
                              'Log in',
                              style: TextStyle(
                                color: blue,
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
    );
  }

  static Widget _line(double width, double height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFE0E5F0),
        borderRadius: BorderRadius.circular(5),
      ),
    );
  }

  static Widget _chip({required double width, required String text}) {
    return Container(
      width: width,
      height: 30,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: blue,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
