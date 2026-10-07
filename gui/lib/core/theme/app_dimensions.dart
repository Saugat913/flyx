import 'package:flutter/material.dart';

abstract final class AppSpace {
  static const screen = 20.0;
  static const card = 16.0;
  static const gap = 12.0;
  static const section = 28.0;
  static const row = 10.0;
  static const minTap = 46.0;
}

abstract final class AppRadius {
  static const card = BorderRadius.all(Radius.circular(20));
  static const button = BorderRadius.all(Radius.circular(12));
  static const input = BorderRadius.all(Radius.circular(12));
  static const checkbox = BorderRadius.all(Radius.circular(4));
  static const chip = BorderRadius.all(Radius.circular(999));
  static const pill = BorderRadius.all(Radius.circular(999)); // alias
  static const sheet = BorderRadius.vertical(top: Radius.circular(24));

  /// Square-ish tiles: icon holders, theme previews.
  static const tileValue = 14.0;
  static const tile = BorderRadius.all(Radius.circular(tileValue));
}
