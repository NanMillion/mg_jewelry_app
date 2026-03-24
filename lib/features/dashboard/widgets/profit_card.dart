import 'package:flutter/material.dart';

class ProfitCard extends StatelessWidget {
  final double revenue;
  final double expense;

  const ProfitCard({
    super.key,
    required this.revenue,
    required this.expense,
  });

  @override
  Widget build(BuildContext context) {
    final profit = revenue - expense;
    final isProfit = profit >= 0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,

      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),

          // 🔥 Background color based on profit
          color: isProfit
              ? Colors.green.withOpacity(0.12)
              : Colors.red.withOpacity(0.12),

          boxShadow: [
            BoxShadow(
              color: (isProfit ? Colors.green : Colors.red)
                  .withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),

        child: Row(
          children: [
            // 🔹 Icon
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: (isProfit ? Colors.green : Colors.red)
                    .withOpacity(0.2),
              ),
              child: Icon(
                isProfit ? Icons.trending_up : Icons.trending_down,
                color: isProfit ? Colors.green : Colors.red,
              ),
            ),

            const SizedBox(width: 14),

            // 🔹 Texts
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Profit",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Revenue - Expense",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            // 🔥 Profit Value
            Text(
              "₹${profit.toStringAsFixed(0)}",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isProfit ? Colors.green : Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }
}