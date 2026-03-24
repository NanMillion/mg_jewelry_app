import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class TopProductsChart extends StatelessWidget {
  final List<Map<String, dynamic>> data;

  const TopProductsChart({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
        child: const Card(
          child: SizedBox(
            height: 150,
            child: Center(child: Text("No product data")),
          ),
        ),
      );
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,

      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 6,
        child: Padding(
          padding: const EdgeInsets.all(16),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "🏆 Top Products",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              SizedBox(
                height: 220,
                child: BarChart(
                  BarChartData(
                    borderData: FlBorderData(show: false),

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

                    titlesData: FlTitlesData(
                      leftTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: true),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),

                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            final index = value.toInt();

                            if (index < 0 || index >= data.length) {
                              return const SizedBox();
                            }

                            final name =
                                (data[index]['name'] ?? '').toString();

                            return Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text(
                                name.length > 6
                                    ? "${name.substring(0, 6)}.."
                                    : name,
                                style: const TextStyle(fontSize: 10),
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                    barGroups: List.generate(data.length, (i) {
                      final qty = (data[i]['qty'] ?? 0).toDouble();

                      return BarChartGroupData(
                        x: i,
                        barRods: [
                          BarChartRodData(
                            toY: qty,
                            width: 18,
                            borderRadius: BorderRadius.circular(6),
                            gradient: const LinearGradient(
                              colors: [
                                Colors.orange,
                                Colors.deepOrange,
                              ],
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // 🔥 VALUES LIST
              Wrap(
                spacing: 12,
                runSpacing: 6,
                children: data.map((item) {
                  final name = item['name'] ?? '';
                  final qty = item['qty'] ?? 0;

                  return Chip(
                    backgroundColor: Colors.white.withOpacity(0.05),
                    label: Text("$name ($qty)"),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}