import 'package:flyx/features/shared/models/file.dart';

enum TransferDirection { sent, received }

enum TransferRecordState { completed, incomplete }

enum TransferHistoryFilter {
  all('All'),
  sent('Sent'),
  received('Received'),
  incomplete('Incomplete');

  final String label;
  const TransferHistoryFilter(this.label);
}

class TransferRecord {
  final String peerName;
  final List<FileModel> files;
  final int totalBytes;
  final TransferDirection direction;
  final TransferRecordState state;
  final DateTime timestamp;

  const TransferRecord({
    required this.peerName,
    required this.files,
    required this.totalBytes,
    required this.direction,
    required this.state,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'peerName': peerName,
    'files': files.map((f) => f.toJson()).toList(),
    'totalBytes': totalBytes,
    'direction': direction.name,
    'state': state.name,
    'timestamp': timestamp.toIso8601String(),
  };

  factory TransferRecord.fromJson(Map<String, dynamic> json) => TransferRecord(
    peerName: json['peerName'] as String? ?? 'Unknown',
    files: (json['files'] as List<dynamic>? ?? const [])
        .map((e) => FileModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList(),
    totalBytes: (json['totalBytes'] as num?)?.toInt() ?? 0,
    direction: TransferDirection.values.firstWhere(
      (d) => d.name == json['direction'],
      orElse: () => TransferDirection.sent,
    ),
    state: TransferRecordState.values.firstWhere(
      (s) => s.name == json['state'],
      orElse: () => TransferRecordState.completed,
    ),
    timestamp:
        DateTime.tryParse(json['timestamp'] as String? ?? '') ??
        DateTime.fromMillisecondsSinceEpoch(0),
  );
}
