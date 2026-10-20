import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flyx/core/di/service_locator.dart';
import 'package:flyx/core/theme/app_dimensions.dart';
import 'package:flyx/core/theme/app_theme.dart';
import 'package:flyx/features/shared/widgets/muted.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:shared_preferences/shared_preferences.dart';

const kDeviceNamePrefKey = 'device_name';
const _deviceChannel = MethodChannel('flyx/device_info');

final deviceName = ValueNotifier<String>('My Device');
String _hardwareDeviceName = 'My Device';
bool _deviceNameInitialized = false;

Future<String> _readProp(String key) async {
  try {
    final res = await Process.run('getprop', [key]);
    if (res.exitCode == 0) {
      return (res.stdout as String).trim();
    }
  } catch (_) {}
  return '';
}

Future<String> resolveSystemDeviceName() async {
  if (!kIsWeb && Platform.isAndroid) {
    try {
      final nativeName = await _deviceChannel.invokeMethod<String>(
        'getDeviceName',
      );
      if (nativeName != null && nativeName.trim().isNotEmpty) {
        return nativeName.trim();
      }
    } catch (_) {
      // Fallback to getprop when native channel isn't loaded yet (e.g. hot reload)
    }

    for (final key in const [
      'persist.sys.device_name',
      'ro.product.marketname',
      'ro.config.marketing_name',
    ]) {
      final value = await _readProp(key);
      if (value.isNotEmpty) return value;
    }

    final brand = await _readProp('ro.product.manufacturer');
    final model = await _readProp('ro.product.model');
    if (model.isNotEmpty) {
      if (brand.isNotEmpty &&
          !model.toLowerCase().startsWith(brand.toLowerCase())) {
        final capBrand = '${brand[0].toUpperCase()}${brand.substring(1)}';
        return '$capBrand $model';
      }
      return model;
    }
    return 'Android Phone';
  }

  if (!kIsWeb) {
    try {
      final host = Platform.localHostname.replaceAll('.local', '').trim();
      if (host.isNotEmpty && host != 'localhost') return host;
    } catch (_) {}
  }

  return 'My Device';
}

Future<void> initDeviceName() async {
  if (_deviceNameInitialized) return;
  _deviceNameInitialized = true;

  _hardwareDeviceName = await resolveSystemDeviceName();
  final saved = getIt.isRegistered<SharedPreferences>()
      ? getIt<SharedPreferences>().getString(kDeviceNamePrefKey)?.trim()
      : null;

  deviceName.value = (saved != null && saved.isNotEmpty)
      ? saved
      : _hardwareDeviceName;
}

class ProfileCard extends StatefulWidget {
  const ProfileCard({super.key});

  @override
  State<ProfileCard> createState() => _ProfileCardState();
}

class _ProfileCardState extends State<ProfileCard> {
  @override
  void initState() {
    super.initState();
    initDeviceName();
  }

  bool get _isMobile => !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  String get _platformLabel {
    if (kIsWeb) return 'Web';
    if (Platform.isAndroid) return 'Android';
    if (Platform.isIOS) return 'iOS';
    if (Platform.isMacOS) return 'macOS';
    if (Platform.isWindows) return 'Windows';
    if (Platform.isLinux) return 'Linux';
    return 'Device';
  }

  Future<void> _saveDeviceName(String nextName) async {
    final trimmed = nextName.trim();
    final effective = trimmed.isEmpty ? _hardwareDeviceName : trimmed;
    deviceName.value = effective;
    if (getIt.isRegistered<SharedPreferences>()) {
      if (effective == _hardwareDeviceName) {
        await getIt<SharedPreferences>().remove(kDeviceNamePrefKey);
      } else {
        await getIt<SharedPreferences>().setString(
          kDeviceNamePrefKey,
          effective,
        );
      }
    }
  }

  Future<void> _rename(BuildContext context) async {
    final name = await showDialog<String>(
      context: context,
      builder: (_) => _RenameDeviceDialog(
        initialName: deviceName.value,
        defaultName: _hardwareDeviceName,
      ),
    );
    if (name != null) {
      await _saveDeviceName(name);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;

    return ValueListenableBuilder<String>(
      valueListenable: deviceName,
      builder: (context, name, _) => Material(
        color: scheme.surfaceContainer,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.card,
          side: BorderSide(color: scheme.outlineVariant),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => _rename(context),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpace.card,
              vertical: 14,
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: scheme.primary,
                    borderRadius: AppRadius.icon,
                  ),
                  child: HugeIcon(
                    icon: _isMobile
                        ? HugeIcons.strokeRoundedSmartPhone01
                        : HugeIcons.strokeRoundedLaptop,
                    size: 20,
                    color: scheme.onPrimary,
                  ),
                ),
                const SizedBox(width: AppSpace.gap),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        name,
                        style: context.textTheme.titleSmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Muted(
                        '$_platformLabel · Tap to rename',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpace.gap),
                HugeIcon(
                  icon: HugeIcons.strokeRoundedEdit02,
                  size: 18,
                  color: scheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RenameDeviceDialog extends StatefulWidget {
  const _RenameDeviceDialog({
    required this.initialName,
    required this.defaultName,
  });

  final String initialName;
  final String defaultName;

  @override
  State<_RenameDeviceDialog> createState() => _RenameDeviceDialogState();
}

class _RenameDeviceDialogState extends State<_RenameDeviceDialog> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initialName,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Device name'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Muted('Nearby devices will see this name when sharing.'),
          const SizedBox(height: AppSpace.gap),
          TextField(
            controller: _controller,
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              hintText: widget.defaultName,
            ),
            onSubmitted: (value) => Navigator.pop(context, value),
          ),
          if (widget.initialName != widget.defaultName) ...[
            const SizedBox(height: AppSpace.row),
            TextButton.icon(
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 6,
                ),
              ),
              onPressed: () => Navigator.pop(context, widget.defaultName),
              icon: HugeIcon(
                icon: HugeIcons.strokeRoundedRefresh,
                size: 15,
                color: context.colorScheme.onSurfaceVariant,
              ),
              label: Text(
                'Use phone default (${widget.defaultName})',
                style: context.textTheme.bodySmall,
              ),
            ),
          ],
        ],
      ),
      actions: [
        OutlinedButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _controller.text),
          child: const Text('Save'),
        ),
      ],
    );
  }
}
