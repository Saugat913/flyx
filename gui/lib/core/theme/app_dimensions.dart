import 'package:flutter/material.dart';

abstract final class AppSpace {
  static const screen = 20.0;
  static const section = 28.0;

  static const card = 16.0;
  static const gap = 12.0;

  static const row = 8.0;
  static const minTap = 48.0;
}

abstract final class AppRadius {
  static const card = BorderRadius.all(Radius.circular(16));
  static const button = BorderRadius.all(Radius.circular(10));
  static const input = BorderRadius.all(Radius.circular(10));
  static const checkbox = BorderRadius.all(Radius.circular(4));
  static const chip = BorderRadius.all(Radius.circular(999));
  static const sheet = BorderRadius.vertical(top: Radius.circular(20));
  static const tile = BorderRadius.all(Radius.circular(12));
  static const icon = BorderRadius.all(Radius.circular(8));
}
