import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class SalesChart extends StatelessWidget {
  final List<Map<String, dynamic>> data;

  const SalesChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Center(child: Text("No data"));
    }

    return SizedBox(
      height: 260,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Colors.white.withOpacity(0.05),
                strokeWidth: 1,
              );
            },
          ),

          borderData: FlBorderData(show: false),

          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: true),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  final i = value.toInt();
                  if (i < 0 || i >= data.length) return const SizedBox();

                  final raw = data[i]['date'];
                  String label = raw.toString().length >= 10
                      ? raw.toString().substring(5, 10)
                      : i.toString();

                  return Text(
                    label,
                    style: const TextStyle(fontSize: 10),
                  );
                },
              ),
            ),
          ),

          lineBarsData: [
            // 🔵 Revenue Line
            LineChartBarData(
              isCurved: true,
              barWidth: 3,
              gradient: const LinearGradient(
                colors: [Colors.blue, Colors.cyan],
              ),

              // 🔥 REMOVE DOTS (clean UI)
              dotData: const FlDotData(show: false),

              // 🔥 AREA FILL (glow effect)
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    Colors.blue.withOpacity(0.3),
                    Colors.transparent,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),

              spots: List.generate(data.length, (i) {
                final val = data[i]['revenue'] ?? 0;
                return FlSpot(i.toDouble(), val.toDouble());
              }),
            ),

            // 🟢 Orders Line
            LineChartBarData(
              isCurved: true,
              barWidth: 3,
              gradient: const LinearGradient(
                colors: [Colors.green, Colors.lightGreen],
              ),

              // 🔥 REMOVE DOTS
              dotData: const FlDotData(show: false),

              // 🔥 AREA FILL
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    Colors.green.withOpacity(0.25),
                    Colors.transparent,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),

              spots: List.generate(data.length, (i) {
                final val = data[i]['orders'] ?? 0;
                return FlSpot(i.toDouble(), val.toDouble());
              }),
            ),
          ],
        ),
      ),
    );
  }
}