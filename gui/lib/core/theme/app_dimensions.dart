import 'package:flutter/material.dart';

abstract final class AppSpace {
  static const screenH = 20.0;
  static const screenV = 16.0;
  static const section = 24.0;

  static const card = 16.0;
  static const gap = 12.0;

  static const row = 8.0;
  static const minTap = 48.0;

  static const wideBreakpoint = 680.0;
  static const maxContentWidth = 680.0;
}

abstract final class AppRadius {
  static const card = BorderRadius.all(Radius.circular(14));
  static const button = BorderRadius.all(Radius.circular(12));
  static const input = BorderRadius.all(Radius.circular(12));
  static const checkbox = BorderRadius.all(Radius.circular(6));
  static const chip = BorderRadius.all(Radius.circular(999));
  static const sheet = BorderRadius.vertical(top: Radius.circular(20));
  static const tile = BorderRadius.all(Radius.circular(14));
  static const icon = BorderRadius.all(Radius.circular(10));
}
