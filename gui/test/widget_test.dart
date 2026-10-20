import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flyx/core/di/service_locator.dart';
import 'package:flyx/core/route/router.dart';
import 'package:flyx/core/viewmodel/view_model.dart';
import 'package:flyx/features/setting/presentation/widgets/profile_card.dart';
import 'package:flyx/features/shared/models/file.dart';
import 'package:flyx/features/shared/models/file_types.dart';
import 'package:flyx/features/shared/models/transfer_record.dart';
import 'package:flyx/features/transfer/presentation/viewmodel/transfer_history_view_model.dart';
import 'package:flyx/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('TransferHistoryViewModel filters and ViewModel.select',
      (tester) async {
    final vm = TransferHistoryViewModel();
    int builds = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: vm.select(
          (v) => v.filteredRecords.length,
          (context, count) {
            builds++;
            return Text('count: $count');
          },
        ),
      ),
    );

    expect(builds, 1);
    expect(find.text('count: 0'), findsOneWidget);

    // Changing unrelated setting does not rebuild filteredRecords count selector
    vm.setAutoAccept(true);
    await tester.pump();
    expect(builds, 1);

    final file = FileModel(
      name: 'demo.jpg',
      path: '/tmp/demo.jpg',
      type: FileType.image,
      size: 1024,
    );

    vm.addRecord(
      peerName: 'Pixel 8',
      files: [file],
      totalBytes: 1024,
      direction: TransferDirection.sent,
      state: TransferRecordState.completed,
    );
    await tester.pump();
    expect(builds, 2);
    expect(find.text('count: 1'), findsOneWidget);

    vm.setFilter(TransferHistoryFilter.received);
    await tester.pump();
    expect(find.text('count: 0'), findsOneWidget);
  });

  testWidgets('AppShell navigation, ProfileCard rename dialog, and hot reload',
      (tester) async {
    SharedPreferences.setMockInitialValues({'onboarded': true});
    await getIt.reset();
    await initDependencies();

    final router = buildRouter(onboarded: true);
    await tester.pumpWidget(FlyxApp(router: router));
    await tester.pump(const Duration(milliseconds: 100));

    // Switch to Settings tab
    await tester.tap(find.text('Settings'));
    await tester.pump(const Duration(milliseconds: 100));

    // Open ProfileCard rename dialog
    await tester.tap(find.byType(ProfileCard));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Device name'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'Galaxy S24');
    await tester.tap(find.text('Save'));
    await tester.pump(const Duration(milliseconds: 300));

    expect(deviceName.value, 'Galaxy S24');

    // Simulate Hot Reload (reassembleApplication schedules a warm-up frame)
    final reassembleFuture = tester.binding.reassembleApplication();
    await tester.pump();
    await reassembleFuture;
  });
}
