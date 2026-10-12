import 'package:flutter/material.dart';

class CampusPilotLogo extends StatelessWidget {
  final double height;
  final BoxFit fit;

  const CampusPilotLogo({
    super.key,
    this.height = 36,
    this.fit = BoxFit.contain,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/campuspilot_logo.png',
      height: height,
      fit: fit,
      filterQuality: FilterQuality.high,
      errorBuilder: (context, error, stackTrace) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: height,
              height: height,
              decoration: BoxDecoration(
                color: const Color(0xFFFAEFF1),
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: const Text(
                'Φ',
                style: TextStyle(
                  color: Color(0xFF7A3345),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'CampusPilot',
              style: TextStyle(
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        );
      },
    );
  }
}
