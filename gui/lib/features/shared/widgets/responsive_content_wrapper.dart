import 'package:flutter/material.dart';
import 'package:flyx/core/theme/app_dimensions.dart';

extension ResponsiveContext on BuildContext {
  double get screenWidth => MediaQuery.sizeOf(this).width;
}

class ResponsiveContentWrapper extends StatelessWidget {
  const ResponsiveContentWrapper({
    required this.child,
    this.maxWidth = AppSpace.maxContentWidth,
    this.padding,
    super.key,
  });

  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    Widget content = SizedBox(width: double.infinity, child: child);
    if (padding != null) {
      content = Padding(padding: padding!, child: content);
    }
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: content,
      ),
    );
  }
}

class ResponsiveBottomBar extends StatelessWidget {
  const ResponsiveBottomBar({
    required this.child,
    this.maxWidth = AppSpace.maxContentWidth,
    this.decoration,
    super.key,
  });

  final Widget child;
  final double maxWidth;
  final Decoration? decoration;

  @override
  Widget build(BuildContext context) {
    final bar = SafeArea(
      child: Align(
        alignment: Alignment.bottomCenter,
        heightFactor: 1,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpace.screenH,
              vertical: AppSpace.screenV,
            ),
            child: SizedBox(width: double.infinity, child: child),
          ),
        ),
      ),
    );
    return decoration != null
        ? DecoratedBox(decoration: decoration!, child: bar)
        : bar;
  }
}
