import 'package:flutter/material.dart';
import 'package:flyx/core/theme/app_theme.dart';

class Muted extends StatelessWidget {
  const Muted(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) =>
      Text(text, style: context.textTheme.bodySmall);
}