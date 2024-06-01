class Message {
  int messageId;
  int transcriptId;
  String messageContent;
  bool isReceived;
  DateTime date;

  Message({
    required this.messageId,
    required this.transcriptId,
    required this.messageContent,
    required this.isReceived,
    required this.date,
  });

  Map<String, dynamic> toJson() {
    return {
      'transcript_id': transcriptId,
      'message_content': messageContent,
      'is_received': isReceived ? 1 : 0,
      'message_date': date.toIso8601String(),
      'ms_since_epoch': date.millisecondsSinceEpoch,
    };
  }

  static Message fromJson(Map<String, dynamic> json) {
    return Message(
      messageId: json['message_id'],
      transcriptId: json['transcript_id'],
      messageContent: json['message_content'],
      isReceived: json['is_received'] == 1,
      date: DateTime.parse(json['message_date']),
    );
  }

  @override
  String toString() {
    return 'Message{messageId: $messageId, transcriptId: $transcriptId, messageContent: $messageContent, isReceived: $isReceived, date: $date}';
  }
}
