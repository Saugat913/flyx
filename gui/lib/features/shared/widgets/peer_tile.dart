import 'package:flutter/material.dart';
import 'package:flyx/core/theme/app_dimensions.dart';
import 'package:flyx/core/theme/app_theme.dart';
import 'package:flyx/features/shared/models/peer.dart';
import 'package:flyx/features/shared/widgets/muted.dart';
import 'package:hugeicons/hugeicons.dart';

class PeerTile extends StatelessWidget {
  const PeerTile({
    super.key,
    required this.peer,
    required this.trailing,
    this.onTap,
  });

  final Peer peer;
  final Widget trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;

    return Material(
      color: scheme.surfaceContainer,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.card,
        side: BorderSide(color: scheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpace.card),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHigh,
                  borderRadius: AppRadius.icon,
                ),
                child: HugeIcon(
                  icon: peer.icon,
                  size: 20,
                  color: scheme.onSurface,
                ),
              ),
              const SizedBox(width: AppSpace.gap),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      peer.name,
                      style: context.textTheme.titleSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Muted('${peer.platform} · ${peer.connectionType}'),
                  ],
                ),
              ),
              const SizedBox(width: AppSpace.gap),
              trailing,
            ],
          ),
        ),
      ),
    );
  }
}
