import 'package:flyx/features/send/data/models/file_types.dart';

class FileModel {
  final String name;
  final String path;
  final FileType type;
  final int size;
  
  FileModel({
    required this.name,
    required this.path,
    required this.type,
    required this.size,
  });


 @override
bool operator ==(Object other) =>
    other is FileModel && other.name == name && other.size == size;

@override
int get hashCode => Object.hash(name, size);
}