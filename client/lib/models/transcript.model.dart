class Transcript {
  int transcriptId;
  String transcriptName;
  DateTime dateCreated;

  Transcript({
    required this.transcriptId,
    required this.transcriptName,
    required this.dateCreated,
  });

  Map<String, dynamic> toJson() {
    return {
      'transcript_name': transcriptName,
      'date_created': dateCreated.toIso8601String(),
    };
  }

  static Transcript fromJson(Map<String, dynamic> json) {
    return Transcript(
      transcriptId: json['transcript_id'],
      transcriptName: json['transcript_name'],
      dateCreated: DateTime.parse(json['date_created']),
    );
  }
}
