import 'dart:async';
import 'dart:math';

import 'package:flyx/core/di/service_locator.dart';
import 'package:flyx/core/viewmodel/view_model.dart';
import 'package:flyx/features/shared/models/file.dart';
import 'package:flyx/features/shared/models/file_types.dart';
import 'package:flyx/features/shared/models/peer.dart';
import 'package:flyx/features/shared/models/transfer_record.dart';
import 'package:flyx/features/transfer/presentation/viewmodel/transfer_history_view_model.dart';
import 'package:hugeicons/hugeicons.dart';

enum ReceiveStatus {
  idle,
  waitingForSender,
  connectingCode,
  incomingRequest,
  receiving,
  completed,
}

class ReceiveViewModel extends ViewModel {
  ReceiveStatus status = ReceiveStatus.idle;
  Peer? senderPeer;
  final List<FileModel> incomingFiles = [];
  final Map<FileModel, double> fileProgress = {};
  int receivedBytes = 0;
  int speedBytesPerSec = 0;

  Timer? _timer;
  int _sessionToken = 0;

  int get totalSize =>
      incomingFiles.fold<int>(0, (sum, file) => sum + file.size);

  double get overallProgress {
    final total = totalSize;
    if (total <= 0) return 0.0;
    return (receivedBytes / total).clamp(0.0, 1.0);
  }

  static final _mockIncomingFiles = [
    FileModel(
      name: 'Screenshot_20261011_172431.jpg',
      path: '/storage/emulated/0/Download/Screenshot_20261011_172431.jpg',
      type: FileType.image,
      size: 108544, // 106 KB
    ),
    FileModel(
      name: 'Project_Demo_Video.mp4',
      path: '/storage/emulated/0/Download/Project_Demo_Video.mp4',
      type: FileType.video,
      size: 4718592, // 4.5 MB
    ),
  ];

  // ponytail: simulated nearby broadcast & incoming request; swap with mDNS/TCP listener when backend is wired
  Future<void> startBroadcasting({void Function()? onAutoAccepted}) async {
    _timer?.cancel();
    final token = ++_sessionToken;
    status = ReceiveStatus.waitingForSender;
    senderPeer = null;
    incomingFiles.clear();
    fileProgress.clear();
    notify();

    await Future<void>.delayed(const Duration(milliseconds: 2400));
    if (token != _sessionToken) return;

    senderPeer = const Peer(
      name: 'Saugat’s MacBook Pro',
      platform: 'macOS',
      connectionType: 'Wi-Fi',
      icon: HugeIcons.strokeRoundedLaptop,
    );
    incomingFiles
      ..clear()
      ..addAll(_mockIncomingFiles);

    if (getIt<TransferHistoryViewModel>().autoAccept) {
      acceptTransfer();
      onAutoAccepted?.call();
      return;
    }

    status = ReceiveStatus.incomingRequest;
    notify();
  }

  Future<bool> connectWithCode(String code) async {
    if (code.length != 6) return false;
    _timer?.cancel();
    final token = ++_sessionToken;
    status = ReceiveStatus.connectingCode;
    notify();

    await Future<void>.delayed(const Duration(milliseconds: 1200));
    if (token != _sessionToken) return false;

    senderPeer = const Peer(
      name: 'Saugat’s MacBook Pro',
      platform: 'macOS',
      connectionType: 'Code',
      icon: HugeIcons.strokeRoundedLaptop,
    );
    incomingFiles
      ..clear()
      ..addAll(_mockIncomingFiles);

    if (getIt<TransferHistoryViewModel>().autoAccept) {
      acceptTransfer();
    } else {
      status = ReceiveStatus.incomingRequest;
      notify();
    }
    return true;
  }

  void acceptTransfer() {
    _timer?.cancel();
    final token = ++_sessionToken;

    status = ReceiveStatus.receiving;
    receivedBytes = 0;
    speedBytesPerSec = 0;
    fileProgress
      ..clear()
      ..addEntries(incomingFiles.map((f) => MapEntry(f, 0.0)));
    notify();

    int currentFileIndex = 0;
    final rng = Random();

    _timer = Timer.periodic(const Duration(milliseconds: 80), (timer) {
      if (token != _sessionToken) {
        timer.cancel();
        return;
      }

      if (currentFileIndex >= incomingFiles.length) {
        timer.cancel();
        receivedBytes = totalSize;
        speedBytesPerSec = 0;
        status = ReceiveStatus.completed;
        getIt<TransferHistoryViewModel>().addRecord(
          peerName: senderPeer?.name ?? 'Sender',
          files: incomingFiles,
          totalBytes: totalSize,
          direction: TransferDirection.received,
          state: TransferRecordState.completed,
        );
        notify();
        return;
      }

      final currentFile = incomingFiles[currentFileIndex];
      final currentProg = fileProgress[currentFile] ?? 0.0;
      final step = 0.04 + rng.nextDouble() * 0.05;
      final nextProg = (currentProg + step).clamp(0.0, 1.0);
      fileProgress[currentFile] = nextProg;

      if (nextProg >= 1.0) {
        currentFileIndex++;
      }

      int sumBytes = 0;
      for (final f in incomingFiles) {
        sumBytes += (f.size * (fileProgress[f] ?? 0.0)).round();
      }
      receivedBytes = sumBytes;
      speedBytesPerSec = 1900000 + rng.nextInt(800000);
      notify();
    });
  }

  void declineOrCancel() {
    if (status == ReceiveStatus.receiving && senderPeer != null) {
      getIt<TransferHistoryViewModel>().addRecord(
        peerName: senderPeer!.name,
        files: incomingFiles,
        totalBytes: totalSize,
        direction: TransferDirection.received,
        state: TransferRecordState.incomplete,
      );
    }
    _sessionToken++;
    _timer?.cancel();
    _timer = null;
    status = ReceiveStatus.idle;
    senderPeer = null;
    incomingFiles.clear();
    fileProgress.clear();
    receivedBytes = 0;
    speedBytesPerSec = 0;
    notify();
  }

  @override
  void dispose() {
    _sessionToken++;
    _timer?.cancel();
    super.dispose();
  }
}
