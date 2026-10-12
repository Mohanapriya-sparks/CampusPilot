import 'dart:async';

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _logoScale;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 950),
    );

    _logoScale = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );

    _fade = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _controller.forward();

    Timer(
      const Duration(milliseconds: 1900),
      () {
        if (!mounted) return;

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => const LoginScreen(),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.background,
                    AppColors.lightTint,
                    AppColors.background,
                  ],
                ),
              ),
            ),
          ),

          // Top-left tint circle
          Positioned(
            top: -120,
            left: -100,
            child: _softCircle(
              size: 330,
              color: AppColors.tint.withOpacity(.55),
            ),
          ),

          // Thin decorative arc
          Positioned(
            top: -100,
            left: -70,
            child: Container(
              width: 390,
              height: 390,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.dustyRose.withOpacity(.45),
                  width: 1,
                ),
              ),
            ),
          ),

          // Right-side neutral tint
          Positioned(
            right: -120,
            top: MediaQuery.of(context).size.height * .38,
            child: _softCircle(
              size: 300,
              color: AppColors.mushroom.withOpacity(.12),
            ),
          ),

          // Bottom blush form
          Positioned(
            left: -80,
            bottom: 40,
            child: _softCircle(
              size: 300,
              color: AppColors.dustyRose.withOpacity(.18),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 28,
              ),
              child: Column(
                children: [
                  const Spacer(flex: 3),
                  ScaleTransition(
                    scale: _logoScale,
                    child: FadeTransition(
                      opacity: _fade,
                      child: Column(
                        children: [
                          Container(
                            width: 82,
                            height: 82,
                            decoration: BoxDecoration(
                              color: AppColors.lightTint,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: AppColors.tint,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: const Text(
                              'Φ',
                              style: TextStyle(
                                color: AppColors.hue,
                                fontSize: 54,
                                fontWeight: FontWeight.w800,
                                height: 1,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          const Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Campus',
                                ),
                                TextSpan(
                                  text: 'Pilot',
                                  style: TextStyle(
                                    color: AppColors.hue,
                                  ),
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.text,
                              fontSize: 36,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -1.2,
                              height: 1,
                            ),
                          ),
                          const SizedBox(height: 15),
                          const Text(
                            'D I S C O V E R   ·   B U I L D   ·   B E L O N G',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.secondary,
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(flex: 3),
                  const SizedBox(
                    width: 38,
                    height: 38,
                    child: CircularProgressIndicator(
                      strokeWidth: 4,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.hue,
                      ),
                      backgroundColor: AppColors.tint,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Preparing your opportunity map',
                    style: TextStyle(
                      color: AppColors.textSoft,
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _softCircle({
    required double size,
    required Color color,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}
