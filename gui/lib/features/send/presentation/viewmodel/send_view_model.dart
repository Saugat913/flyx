import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:flyx/core/di/service_locator.dart';
import 'package:flyx/core/services/file_picker_service.dart';
import 'package:flyx/core/viewmodel/view_model.dart';
import 'package:flyx/features/send/data/models/file.dart';
import 'package:flyx/features/send/data/models/peer.dart';
import 'package:hugeicons/hugeicons.dart';

class SendViewModel extends ViewModel {
  final Set<FileModel> selectedFiles = {};
  final List<Peer> discoveredPeers = [];
  StreamSubscription<Peer>? _scanSub;

  bool get isEmpty => selectedFiles.isEmpty;
  int get selectedCount => selectedFiles.length;
  int get totalSize =>
      selectedFiles.fold<int>(0, (sum, file) => sum + file.size);

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
    stopDiscovery();
    super.dispose();
  }
}
