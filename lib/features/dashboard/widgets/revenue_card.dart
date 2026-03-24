import 'package:flutter/material.dart';

class RevenueCard extends StatelessWidget {
  final double revenue;

  const RevenueCard({
    super.key,
    required this.revenue,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,

      // 🔥 animation effect
      transform: Matrix4.identity()..scale(1.02),

      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),

          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.green.withOpacity(0.1),
            ),
            child: const Icon(
              Icons.currency_rupee,
              color: Colors.green,
            ),
          ),

          title: const Text(
            "Total Revenue",
            style: TextStyle(fontWeight: FontWeight.w600),
          ),

          subtitle: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              "₹${revenue.toStringAsFixed(0)}",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}