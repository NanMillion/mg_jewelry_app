import 'package:flutter/material.dart';

class HeroWrapper extends StatelessWidget {
  final String tag;
  final Widget child;

  const HeroWrapper({
    super.key,
    required this.tag,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: tag,
      flightShuttleBuilder: (flightContext, animation, direction,
          fromContext, toContext) {
        return ScaleTransition(
          scale: animation,
          child: child,
        );
      },
      child: child,
    );
  }
}