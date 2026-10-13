import 'package:hugeicons/hugeicons.dart';

enum FileType {
  image(HugeIcons.strokeRoundedImage01),
  video(HugeIcons.strokeRoundedVideo01),
  document(HugeIcons.strokeRoundedDocumentAttachment),
  audio(HugeIcons.strokeRoundedAudioWave01),
  archive(HugeIcons.strokeRoundedArchive01),
  other(HugeIcons.strokeRoundedFile01);

  final List<List<dynamic>> icon;
  const FileType(this.icon);


  static FileType fromExtension(String extension) {
    switch (extension) {
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return FileType.image;
      case 'mp4':
      case 'avi':
      case 'mkv':
        return FileType.video;
      case 'pdf':
      case 'doc':
      case 'docx':
        return FileType.document;
      case 'mp3':
      case 'wav':
        return FileType.audio;
      case 'zip':
      case 'rar':
        return FileType.archive;
      default:
        return FileType.other;
    }
  }
}