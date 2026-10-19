import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';


abstract class ViewModel extends ChangeNotifier {
  @protected
  void notify() => notifyListeners();
}

extension ViewModelExtension<T extends Listenable> on T {
  /// Rebuilds whenever [notify] is called on this ViewModel.
  Widget watch(Widget Function(BuildContext context, T vm) builder) {
    return ListenableBuilder(
      listenable: this,
      builder: (context, _) => builder(context, this),
    );
  }

  /// Rebuilds ONLY when the value returned by [selector] changes.
  Widget select<R>(
    R Function(T vm) selector,
    Widget Function(BuildContext context, R value) builder,
  ) {
    return _SelectBuilder<T, R>(
      listenable: this,
      selector: selector,
      builder: builder,
    );
  }
}

class _SelectBuilder<T extends Listenable, R> extends StatefulWidget {
  const _SelectBuilder({
    required this.listenable,
    required this.selector,
    required this.builder,
  });

  final T listenable;
  final R Function(T vm) selector;
  final Widget Function(BuildContext context, R value) builder;

  @override
  State<_SelectBuilder<T, R>> createState() => _SelectBuilderState<T, R>();
}

class _SelectBuilderState<T extends Listenable, R>
    extends State<_SelectBuilder<T, R>> {
  late R _value;

  @override
  void initState() {
    super.initState();
    _value = widget.selector(widget.listenable);
    widget.listenable.addListener(_onChanged);
  }

  @override
  void didUpdateWidget(covariant _SelectBuilder<T, R> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.listenable != widget.listenable) {
      oldWidget.listenable.removeListener(_onChanged);
      _value = widget.selector(widget.listenable);
      widget.listenable.addListener(_onChanged);
    }
  }

  @override
  void dispose() {
    widget.listenable.removeListener(_onChanged);
    super.dispose();
  }

  bool _equals(R a, R b) {
    if (a is List && b is List) return listEquals(a, b);
    if (a is Set && b is Set) return setEquals(a, b);
    return a == b;
  }

  void _onChanged() {
    final next = widget.selector(widget.listenable);
    if (!_equals(next, _value)) {
      setState(() => _value = next);
    }
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, _value);
}
