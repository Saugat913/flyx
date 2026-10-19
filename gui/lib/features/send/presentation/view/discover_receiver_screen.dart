import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';

class DiscoverReceiverScreen extends StatelessWidget {
  const DiscoverReceiverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
         title: const Text('Discover Receiver'),
            leading: IconButton(
              icon: HugeIcon(icon: HugeIcons.strokeRoundedChevronLeft),
              onPressed: () => context.pop(),
            )
          ),
      body: Center(
        child: Text('Discover Receiver'),
      ),
    );
  }
}