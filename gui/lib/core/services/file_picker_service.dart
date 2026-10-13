import 'package:file_picker/file_picker.dart' as fp;
import 'package:flyx/features/send/data/models/file.dart';
import 'package:flyx/features/send/data/models/file_types.dart';

class FilePickerService {
  Future<List<FileModel>> pickFiles() async {
    final result = await fp.FilePicker.pickFiles(
      type: fp.FileType.any,
    );

    final files = <FileModel>[];

    for (final file in result) {
      final filePath = file.path;
      final fileSize = await file.length();

      if (filePath == null || fileSize == null) continue;
      
      files.add(
        FileModel(
          name: file.name,
          path: filePath,
          size: fileSize,
          type: FileType.fromExtension(file.extension ?? ''),
        ),
      );
    }

    return files;
  }
}
