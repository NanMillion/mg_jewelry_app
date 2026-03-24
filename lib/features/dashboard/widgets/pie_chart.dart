import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class DashboardPieChart extends StatelessWidget {
  final int revenue;
  final int orders;
  final int users;

  const DashboardPieChart({
    super.key,
    required this.revenue,
    required this.orders,
    required this.users,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,

      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white.withOpacity(0.03),
        ),

        child: SizedBox(
          height: 220,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 40,

              sections: [
                PieChartSectionData(
                  value: revenue.toDouble(),
                  color: Colors.blue,
                  title: "Revenue",
                  radius: 50,
                  titleStyle: const TextStyle(
                    fontSize: 10,
                    color: Colors.white,
                  ),
                ),
                PieChartSectionData(
                  value: orders.toDouble(),
                  color: Colors.green,
                  title: "Orders",
                  radius: 50,
                  titleStyle: const TextStyle(
                    fontSize: 10,
                    color: Colors.white,
                  ),
                ),
                PieChartSectionData(
                  value: users.toDouble(),
                  color: Colors.orange,
                  title: "Users",
                  radius: 50,
                  titleStyle: const TextStyle(
                    fontSize: 10,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}