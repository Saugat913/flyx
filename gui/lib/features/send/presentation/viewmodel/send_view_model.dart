import 'package:file_picker/file_picker.dart';
import 'package:flyx/core/di/service_locator.dart';
import 'package:flyx/core/services/file_picker_service.dart';
import 'package:flyx/features/send/data/models/file.dart';
import 'package:flutter/material.dart';

class SendViewModel  {
  SendViewModel();
  final _selectedFiles = ValueNotifier<Set<FileModel>>({});

  ValueNotifier<Set<FileModel>> get selectedFiles => _selectedFiles;
 

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
    FilePicker.clearTemporaryFiles();
    _selectedFiles.value = {};
  }

  Future<int> pickFiles() async {
    final filePickerService = getIt<FilePickerService>();
    final files = await filePickerService.pickFiles();

    final previousCount = selectedFiles.value.length;
    _selectedFiles.value.addAll(files);

    return previousCount + files.length;
  }

}
