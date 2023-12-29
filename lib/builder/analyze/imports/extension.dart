String fileExtension(String filePath) {
  return Uri.file(filePath).path.split('.').last.replaceFirst('\'', '');
}