import 'package:flutter/material.dart';
import 'package:flyx/core/route/route_config.dart';
import 'package:go_router/go_router.dart';

extension AppNavigation on BuildContext {
  void goTo(AppRoute route) {
    go(route.path);
  }

  void pushTo(AppRoute route) {
    push(route.path);
  }

  void replaceTo(AppRoute route) {
    pushReplacement(route.path);
  }

  void popRoute() {
    pop();
  }

  bool get canPopRoute => canPop();
}