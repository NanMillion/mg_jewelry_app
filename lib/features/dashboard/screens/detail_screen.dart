import 'package:flutter/material.dart';
import 'package:mg_jewelry/core/hero_wrapper.dart';

class DetailScreen extends StatelessWidget {
  final String title;
  final String value;
  final String tag;

  const DetailScreen({
    super.key,
    required this.title,
    required this.value,
    required this.tag,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020617),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(title),
      ),
      body: Center(
        child: HeroWrapper(
          tag: tag,
          child: Container(
            width: 250,
            height: 150,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(
                colors: [Colors.orange, Colors.deepOrange],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.orange.withOpacity(0.5),
                  blurRadius: 30,
                ),
              ],
            ),
            child: Center(
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}