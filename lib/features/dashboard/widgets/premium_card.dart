import 'package:flutter/material.dart';

class PremiumCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const PremiumCard({
    super.key,
    required this.title,
    required this.value,
    required this.color,
  });

  // 🔥 Extract number safely (for animation)
  int _extractNumber(String value) {
    final numeric = value.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(numeric) ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final number = _extractNumber(value);
    final isCurrency = value.contains('₹');

    return Expanded(
      child: TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOutBack,
        tween: Tween(begin: 0.8, end: 1),
        builder: (context, scale, _) {
          return Transform.scale(
            scale: scale,

            // 🔥 NEW: AnimatedContainer added here
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOut,

              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),

                // 🔥 Gradient glow
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    color.withOpacity(0.9),
                    color.withOpacity(0.4),
                  ],
                ),

                // 🔥 Neon shadow
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.6),
                    blurRadius: 25,
                    spreadRadius: 1,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🔹 Title
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),

                  const SizedBox(height: 10),

                  // 🔥 Animated number counter
                  TweenAnimationBuilder<int>(
                    duration: const Duration(milliseconds: 900),
                    tween: IntTween(begin: 0, end: number),
                    builder: (context, val, _) {
                      return Text(
                        isCurrency ? "₹$val" : "$val",
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}