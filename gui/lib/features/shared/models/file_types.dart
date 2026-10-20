import 'package:hugeicons/hugeicons.dart';

enum FileType {
  image(HugeIcons.strokeRoundedImage01, 'photos'),
  video(HugeIcons.strokeRoundedVideo01, 'videos'),
  document(HugeIcons.strokeRoundedDocumentAttachment, 'documents'),
  audio(HugeIcons.strokeRoundedAudioWave01, 'audio files'),
  archive(HugeIcons.strokeRoundedArchive01, 'archives'),
  other(HugeIcons.strokeRoundedFile01, 'files');

  final List<List<dynamic>> icon;
  final String pluralLabel;
  const FileType(this.icon, this.pluralLabel);

  static FileType fromExtension(String extension) {
    switch (extension) {
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
      case 'webp':
        return FileType.image;
      case 'mp4':
      case 'avi':
      case 'mkv':
      case 'mov':
        return FileType.video;
      case 'pdf':
      case 'doc':
      case 'docx':
      case 'txt':
        return FileType.document;
      case 'mp3':
      case 'wav':
      case 'flac':
        return FileType.audio;
      case 'zip':
      case 'rar':
      case '7z':
      case 'tar':
        return FileType.archive;
      default:
        return FileType.other;
    }
  }
}
