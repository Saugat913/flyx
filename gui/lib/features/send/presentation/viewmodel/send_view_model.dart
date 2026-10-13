import 'package:flyx/features/send/data/models/file.dart';
import 'package:flutter/material.dart';

class SendViewModel extends ChangeNotifier {
  SendViewModel();
  final _selectedFiles = ValueNotifier<Set<FileModel>>({});

  ValueNotifier<Set<FileModel>> get selectedFiles => _selectedFiles;
  bool get isSelectedFilesEmpty => _selectedFiles.value.isEmpty;
  int get selectedFilesCount => _selectedFiles.value.length;

  void addFiles(Iterable<FileModel> files) {
    final updatedFiles = Set<FileModel>.from(_selectedFiles.value);
    updatedFiles.addAll(files);
    _selectedFiles.value = updatedFiles;
  }

  void removeFile(FileModel file) {
    final updatedFiles = Set<FileModel>.from(_selectedFiles.value);
    updatedFiles.remove(file);
    _selectedFiles.value = updatedFiles;
  }

  void clear() {
    _selectedFiles.value = {};
  }

  @override
  void dispose() {
    _selectedFiles.dispose();
    super.dispose();
  }
}
