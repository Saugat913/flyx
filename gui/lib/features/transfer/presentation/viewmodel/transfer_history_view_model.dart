import 'dart:convert';

import 'package:flyx/core/di/service_locator.dart';
import 'package:flyx/core/viewmodel/view_model.dart';
import 'package:flyx/features/shared/models/file.dart';
import 'package:flyx/features/shared/models/transfer_record.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kHistoryPrefKey = 'transfer_history';
const _kAutoAcceptPrefKey = 'setting_auto_accept';
const _kTrustedPeersPrefKey = 'setting_trusted_peers';
const _kTransferSoundsPrefKey = 'setting_transfer_sounds';
const _kMaxHistoryRecords = 200;

class TransferHistoryViewModel extends ViewModel {
  TransferHistoryViewModel() {
    _loadFromPrefs();
  }

  final List<TransferRecord> records = [];
  TransferHistoryFilter filter = TransferHistoryFilter.all;

  bool autoAccept = false;
  bool trustedPeers = true;
  bool transferSounds = true;

  SharedPreferences? get _prefs => getIt.isRegistered<SharedPreferences>()
      ? getIt<SharedPreferences>()
      : null;

  void _loadFromPrefs() {
    final prefs = _prefs;
    if (prefs == null) return;

    autoAccept = prefs.getBool(_kAutoAcceptPrefKey) ?? false;
    trustedPeers = prefs.getBool(_kTrustedPeersPrefKey) ?? true;
    transferSounds = prefs.getBool(_kTransferSoundsPrefKey) ?? true;

    final rawList = prefs.getStringList(_kHistoryPrefKey);
    if (rawList != null && rawList.isNotEmpty) {
      for (final raw in rawList) {
        try {
          final decoded = jsonDecode(raw) as Map<String, dynamic>;
          records.add(TransferRecord.fromJson(decoded));
        } catch (_) {}
      }
    }
  }

  void _saveRecords() {
    final prefs = _prefs;
    if (prefs == null) return;
    final encoded = records
        .take(_kMaxHistoryRecords)
        .map((r) => jsonEncode(r.toJson()))
        .toList();
    prefs.setStringList(_kHistoryPrefKey, encoded);
  }

  List<TransferRecord> get filteredRecords => switch (filter) {
    TransferHistoryFilter.all => records,
    TransferHistoryFilter.sent =>
      records
          .where(
            (r) =>
                r.direction == TransferDirection.sent &&
                r.state == TransferRecordState.completed,
          )
          .toList(),
    TransferHistoryFilter.received =>
      records
          .where(
            (r) =>
                r.direction == TransferDirection.received &&
                r.state == TransferRecordState.completed,
          )
          .toList(),
    TransferHistoryFilter.incomplete =>
      records.where((r) => r.state == TransferRecordState.incomplete).toList(),
  };

  void setFilter(TransferHistoryFilter value) {
    if (filter == value) return;
    filter = value;
    notify();
  }

  void addRecord({
    required String peerName,
    required Iterable<FileModel> files,
    required int totalBytes,
    required TransferDirection direction,
    required TransferRecordState state,
  }) {
    final fileList = files.toList();
    if (fileList.isEmpty) return;
    records.insert(
      0,
      TransferRecord(
        peerName: peerName,
        files: fileList,
        totalBytes: totalBytes,
        direction: direction,
        state: state,
        timestamp: DateTime.now(),
      ),
    );
    if (records.length > _kMaxHistoryRecords) {
      records.removeRange(_kMaxHistoryRecords, records.length);
    }
    _saveRecords();
    notify();
  }

  void clearHistory() {
    if (records.isEmpty) return;
    records.clear();
    _prefs?.remove(_kHistoryPrefKey);
    notify();
  }

  void setAutoAccept(bool value) {
    autoAccept = value;
    _prefs?.setBool(_kAutoAcceptPrefKey, value);
    notify();
  }

  void setTrustedPeers(bool value) {
    trustedPeers = value;
    _prefs?.setBool(_kTrustedPeersPrefKey, value);
    notify();
  }

  void setTransferSounds(bool value) {
    transferSounds = value;
    _prefs?.setBool(_kTransferSoundsPrefKey, value);
    notify();
  }
}
