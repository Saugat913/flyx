import 'dart:async';
import 'dart:math';

import 'package:file_picker/file_picker.dart';
import 'package:flyx/core/di/service_locator.dart';
import 'package:flyx/core/services/file_picker_service.dart';
import 'package:flyx/core/viewmodel/view_model.dart';
import 'package:flyx/features/shared/models/file.dart';
import 'package:flyx/features/shared/models/peer.dart';
import 'package:flyx/features/shared/models/transfer_record.dart';
import 'package:flyx/features/transfer/presentation/viewmodel/transfer_history_view_model.dart';
import 'package:hugeicons/hugeicons.dart';

enum TransferStatus { idle, waitingAcceptance, transferring, completed }

class SendViewModel extends ViewModel {
  final Set<FileModel> selectedFiles = {};
  final List<Peer> discoveredPeers = [];
  String? shareCode;

  TransferStatus transferStatus = TransferStatus.idle;
  Peer? activePeer;
  final Map<FileModel, double> fileProgress = {};
  int transferredBytes = 0;
  int speedBytesPerSec = 0;

  StreamSubscription<Peer>? _scanSub;
  Timer? _transferTimer;
  int _sessionToken = 0;

  bool get isEmpty => selectedFiles.isEmpty;
  int get selectedCount => selectedFiles.length;
  int get totalSize =>
      selectedFiles.fold<int>(0, (sum, file) => sum + file.size);

  double get overallProgress {
    final total = totalSize;
    if (total <= 0) {
      if (fileProgress.isEmpty) return 0;
      return fileProgress.values.fold<double>(0, (a, b) => a + b) /
          fileProgress.length;
    }
    return (transferredBytes / total).clamp(0.0, 1.0);
  }

  String? get formattedShareCode {
    final code = shareCode;
    if (code == null) return null;
    return '${code.substring(0, 3).split('').join(' ')}   ${code.substring(3).split('').join(' ')}';
  }

  // ponytail: simulated signaling + receiver acceptance; swap delays with real signaling socket events
  Future<void> generateShareCode({void Function()? onPeerAccepted}) async {
    final token = ++_sessionToken;
    if (shareCode != null) {
      shareCode = null;
      notify();
    }

    await Future<void>.delayed(const Duration(milliseconds: 1200));
    if (token != _sessionToken) return;
    shareCode = (100000 + Random().nextInt(900000)).toString();
    notify();

    // Simulate receiver entering the 6-digit code after 3s
    await Future<void>.delayed(const Duration(seconds: 3));
    if (token != _sessionToken) return;
    onPeerAccepted?.call();
    startTransfer(
      const Peer(
        name: 'Saugat’s MacBook Pro',
        platform: 'macOS',
        connectionType: 'Code',
        icon: HugeIcons.strokeRoundedLaptop,
      ),
    );
  }

  void cancelShareCode() {
    _sessionToken++;
    shareCode = null;
  }

  Future<void> startTransfer(Peer peer) async {
    stopDiscovery();
    _transferTimer?.cancel();
    final token = ++_sessionToken;

    activePeer = peer;
    transferStatus = TransferStatus.waitingAcceptance;
    transferredBytes = 0;
    speedBytesPerSec = 0;
    fileProgress
      ..clear()
      ..addEntries(selectedFiles.map((f) => MapEntry(f, 0.0)));
    notify();

    // Simulate waiting for receiver to accept the incoming transfer request
    await Future<void>.delayed(const Duration(milliseconds: 1600));
    if (token != _sessionToken) return;

    transferStatus = TransferStatus.transferring;
    final files = selectedFiles.toList();
    if (files.isEmpty) {
      transferStatus = TransferStatus.completed;
      notify();
      return;
    }

    int currentFileIndex = 0;
    final rng = Random();

    _transferTimer = Timer.periodic(const Duration(milliseconds: 80), (timer) {
      if (token != _sessionToken) {
        timer.cancel();
        return;
      }

      if (currentFileIndex >= files.length) {
        timer.cancel();
        transferredBytes = totalSize;
        speedBytesPerSec = 0;
        transferStatus = TransferStatus.completed;
        getIt<TransferHistoryViewModel>().addRecord(
          peerName: peer.name,
          files: files,
          totalBytes: totalSize,
          direction: TransferDirection.sent,
          state: TransferRecordState.completed,
        );
        notify();
        return;
      }

      final currentFile = files[currentFileIndex];
      final currentProg = fileProgress[currentFile] ?? 0.0;
      final step = 0.04 + rng.nextDouble() * 0.05;
      final nextProg = (currentProg + step).clamp(0.0, 1.0);
      fileProgress[currentFile] = nextProg;

      if (nextProg >= 1.0) {
        currentFileIndex++;
      }

      // Compute total transferred bytes across all files
      int sumBytes = 0;
      for (final f in files) {
        sumBytes += (f.size * (fileProgress[f] ?? 0.0)).round();
      }
      transferredBytes = sumBytes;
      speedBytesPerSec = 1800000 + rng.nextInt(900000); // ~1.8 - 2.7 MB/s
      notify();
    });
  }

  void cancelTransfer() {
    if (transferStatus == TransferStatus.transferring && activePeer != null) {
      getIt<TransferHistoryViewModel>().addRecord(
        peerName: activePeer!.name,
        files: selectedFiles,
        totalBytes: totalSize,
        direction: TransferDirection.sent,
        state: TransferRecordState.incomplete,
      );
    }
    _sessionToken++;
    _transferTimer?.cancel();
    _transferTimer = null;
    transferStatus = TransferStatus.idle;
    activePeer = null;
    fileProgress.clear();
    transferredBytes = 0;
    speedBytesPerSec = 0;
    notify();
  }

  void addFiles(Iterable<FileModel> files) {
    selectedFiles.addAll(files);
    notify();
  }

  void removeFile(FileModel file) {
    if (selectedFiles.remove(file)) notify();
  }

  void clear() {
    FilePicker.clearTemporaryFiles();
    selectedFiles.clear();
    notify();
  }

  Future<int> pickFiles() async {
    final files = await getIt<FilePickerService>().pickFiles();
    final previousCount = selectedFiles.length;
    selectedFiles.addAll(files);
    if (files.isNotEmpty) notify();
    return previousCount + files.length;
  }

  Stream<Peer> _mockPeerStream() =>
      Stream.fromIterable(const [
        Peer(
          name: 'Saugat’s MacBook Pro',
          platform: 'macOS',
          connectionType: 'Wi-Fi',
          icon: HugeIcons.strokeRoundedLaptop,
        ),
        Peer(
          name: 'Pixel 8',
          platform: 'Android',
          connectionType: 'Wi-Fi',
          icon: HugeIcons.strokeRoundedSmartPhone01,
        ),
        Peer(
          name: 'iPad Air',
          platform: 'iPadOS',
          connectionType: 'Wi-Fi',
          icon: HugeIcons.strokeRoundedTablet01,
        ),
      ]).asyncMap(
        (p) => Future.delayed(const Duration(milliseconds: 1100), () => p),
      );

  void startDiscovery() {
    stopDiscovery();
    discoveredPeers.clear();
    notify();

    _scanSub = _mockPeerStream().listen((peer) {
      discoveredPeers.add(peer);
      notify();
    });
  }

  void stopDiscovery() => _scanSub?.cancel();

  @override
  void dispose() {
    _sessionToken++;
    stopDiscovery();
    _transferTimer?.cancel();
    FilePicker.clearTemporaryFiles();
    selectedFiles.clear();
    super.dispose();
  }
}
