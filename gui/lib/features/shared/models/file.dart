import 'package:flyx/features/shared/models/file_types.dart';

class FileModel {
  final String name;
  final String path;
  final FileType type;
  final int size;

  const FileModel({
    required this.name,
    required this.path,
    required this.type,
    required this.size,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'path': path,
    'type': type.name,
    'size': size,
  };

  factory FileModel.fromJson(Map<String, dynamic> json) => FileModel(
    name: json['name'] as String? ?? '',
    path: json['path'] as String? ?? '',
    type: FileType.values.firstWhere(
      (t) => t.name == json['type'],
      orElse: () => FileType.other,
    ),
    size: (json['size'] as num?)?.toInt() ?? 0,
  );

  @override
  bool operator ==(Object other) =>
      other is FileModel && other.name == name && other.size == size;

  @override
  int get hashCode => Object.hash(name, size);
}
