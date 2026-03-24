import 'package:flutter/material.dart';

class HeatmapWidget extends StatelessWidget {
  final List<List<double>> data;

  const HeatmapWidget({super.key, required this.data});

  Color _color(double v) {
    return Color.lerp(Colors.green.shade100, Colors.green.shade800, v)!;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: data.map((row) {
        return Row(
          children: row.map((v) {
            return Expanded(
              child: Container(
                margin: const EdgeInsets.all(2),
                height: 20,
                color: _color(v),
              ),
            );
          }).toList(),
        );
      }).toList(),
    );
  }
}