import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class StackedChart extends StatelessWidget {
  const StackedChart({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          barGroups: [
            BarChartGroupData(x: 0, barRods: [
              BarChartRodData(
                toY: 100,
                rodStackItems: [
                  BarChartRodStackItem(0, 40, Colors.blue),
                  BarChartRodStackItem(40, 100, Colors.green),
                ],
              )
            ])
          ],
        ),
      ),
    );
  }
}