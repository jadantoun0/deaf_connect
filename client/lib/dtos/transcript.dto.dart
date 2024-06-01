import 'package:deafconnect/models/message.model.dart';

class TranscriptDTO {
  int transcriptId;
  String transcriptName;
  DateTime dateCreated;
  List<Message> messages;

  TranscriptDTO({
    required this.transcriptId,
    required this.transcriptName,
    required this.dateCreated,
    required this.messages,
  });

  Map<String, dynamic> toJson() {
    return {
      'transcript_id': transcriptId,
      'transcript_name': transcriptName,
      'date_created': dateCreated.toIso8601String(),
      'messages': messages,
    };
  }

  @override
  String toString() {
    return 'TranscriptDTO{transcriptId: $transcriptId, transcriptName: $transcriptName, dateCreated: $dateCreated, messages: $messages}';
  }
}
