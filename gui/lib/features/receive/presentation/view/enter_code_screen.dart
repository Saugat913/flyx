import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flyx/core/di/service_locator.dart';
import 'package:flyx/core/route/route_config.dart';
import 'package:flyx/core/route/route_navigation.dart';
import 'package:flyx/core/theme/app_dimensions.dart';
import 'package:flyx/core/theme/app_theme.dart';
import 'package:flyx/core/viewmodel/view_model.dart';
import 'package:flyx/features/receive/presentation/viewmodel/receive_view_model.dart';
import 'package:flyx/features/shared/widgets/muted.dart';
import 'package:flyx/features/shared/widgets/responsive_content_wrapper.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';

class EnterCodeScreen extends StatefulWidget {
  const EnterCodeScreen({super.key});

  @override
  State<EnterCodeScreen> createState() => _EnterCodeScreenState();
}

class _EnterCodeScreenState extends State<EnterCodeScreen> {
  final _vm = getIt<ReceiveViewModel>();
  final _controllers = List.generate(6, (_) => TextEditingController());
  final _focusNodes = List.generate(6, (_) => FocusNode());

  String get _code => _controllers.map((c) => c.text).join();
  bool get _isComplete => _code.length == 6;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNodes.first.requestFocus();
    });
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _fillDigits(String raw) {
    final digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return;

    for (var i = 0; i < 6; i++) {
      _controllers[i].text = i < digits.length ? digits[i] : '';
    }
    final nextIndex = digits.length.clamp(0, 5);
    _focusNodes[nextIndex].requestFocus();
    setState(() {});
  }

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text;
    if (text == null || text.isEmpty) return;
    _fillDigits(text);
  }

  Future<void> _connect() async {
    if (!_isComplete) return;
    FocusScope.of(context).unfocus();
    final connected = await _vm.connectWithCode(_code);
    if (connected && mounted) {
      context.replaceTo(AppRoute.receiveTransfer);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Enter Code'),
        leading: IconButton(
          icon: HugeIcon(
            icon: HugeIcons.strokeRoundedChevronLeft,
            color: scheme.onSurface,
          ),
          onPressed: () => context.pop(),
        ),
      ),
      bottomNavigationBar: ResponsiveBottomBar(
        child: _vm.select(
          (vm) => vm.status == ReceiveStatus.connectingCode,
          (context, isConnecting) => SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: (!_isComplete || isConnecting) ? null : _connect,
              child: isConnecting
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: scheme.onPrimary,
                      ),
                    )
                  : const Text('Connect'),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: ResponsiveContentWrapper(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpace.screenH,
              vertical: AppSpace.screenV,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpace.card,
                    vertical: AppSpace.section,
                  ),
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainer,
                    borderRadius: AppRadius.card,
                    border: Border.all(color: scheme.outlineVariant),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: scheme.surfaceContainerHigh,
                          borderRadius: AppRadius.card,
                          border: Border.all(color: scheme.outlineVariant),
                        ),
                        child: HugeIcon(
                          icon: HugeIcons.strokeRoundedPin,
                          size: 24,
                          color: scheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: AppSpace.card),
                      Text(
                        'Enter 6-digit code',
                        style: context.textTheme.titleMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      const Muted('Ask the sender for their transfer code'),
                      const SizedBox(height: AppSpace.section),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 360),
                        child: Row(
                          spacing: AppSpace.row,
                          children: List.generate(6, (index) {
                            return Expanded(
                              child: SizedBox(
                                height: 54,
                                child: KeyboardListener(
                                  focusNode: FocusNode(skipTraversal: true),
                                  onKeyEvent: (event) {
                                    if (event is KeyDownEvent &&
                                        event.logicalKey ==
                                            LogicalKeyboardKey.backspace &&
                                        _controllers[index].text.isEmpty &&
                                        index > 0) {
                                      _controllers[index - 1].clear();
                                      _focusNodes[index - 1].requestFocus();
                                      setState(() {});
                                    }
                                  },
                                  child: TextField(
                                    controller: _controllers[index],
                                    focusNode: _focusNodes[index],
                                    keyboardType: TextInputType.number,
                                    textAlign: TextAlign.center,
                                    style: context.textTheme.titleMedium
                                        ?.copyWith(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w800,
                                        ),
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                    ],
                                    decoration: const InputDecoration(
                                      counterText: '',
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                    onChanged: (value) {
                                      if (value.length > 1) {
                                        _fillDigits(value);
                                        return;
                                      }
                                      if (value.isNotEmpty && index < 5) {
                                        _focusNodes[index + 1].requestFocus();
                                      }
                                      setState(() {});
                                    },
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                      const SizedBox(height: AppSpace.section),
                      OutlinedButton.icon(
                        onPressed: _pasteFromClipboard,
                        icon: HugeIcon(
                          icon: HugeIcons.strokeRoundedCopy01,
                          size: 18,
                          color: scheme.onSurface,
                        ),
                        label: const Text('Paste code'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
