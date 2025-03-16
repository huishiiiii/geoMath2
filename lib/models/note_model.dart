class NoteModel {
  final String title;
  final String? classId;
  final String? instruction;
  final String? fileName;
  final String? fileUrl;
  final String? source;
  final String? year;
  final Map<String, dynamic>? noteDetails;

  NoteModel(
      {required this.title,
      this.classId,
      this.instruction,
      this.fileName,
      this.fileUrl,
      this.source,
      this.year,
      this.noteDetails});
}
