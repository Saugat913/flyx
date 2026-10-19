import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';

class ShareCodeScreen extends StatelessWidget {
  const ShareCodeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
         title: const Text('Share Code'),
            leading: IconButton(
              icon: HugeIcon(icon: HugeIcons.strokeRoundedChevronLeft),
              onPressed: () => context.pop(),
            )
          ),
      body: Center(
        child: Text('Share Code'),
      ),
    );
  }
}