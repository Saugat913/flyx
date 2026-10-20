import 'package:flutter/material.dart';
import 'package:flyx/core/theme/app_theme.dart';

class Muted extends StatelessWidget {
  const Muted(
    this.text, {
    super.key,
    this.style,
    this.maxLines,
    this.overflow,
  });

  final String text;
  final TextStyle? style;
  final int? maxLines;
  final TextOverflow? overflow;

  @override
  Widget build(BuildContext context) => Text(
    text,
    maxLines: maxLines,
    overflow: overflow,
    style: style ?? context.textTheme.bodySmall,
  );
}
