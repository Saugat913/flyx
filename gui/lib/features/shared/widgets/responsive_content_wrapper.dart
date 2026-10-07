import 'package:flutter/material.dart';

class ResponsiveContentWrapper extends StatelessWidget {
  const ResponsiveContentWrapper({
    required this.child,
    this.maxWidth=720,
    super.key,
  });

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}