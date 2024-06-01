class AvatarMessage {
  int id;
  String message;

  AvatarMessage({
    required this.id,
    required this.message,
  });

  factory AvatarMessage.fromJson(Map<String, dynamic> json) {
    return AvatarMessage(
      id: json['avatar_message_id'],
      message: json['avatar_message'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'avatar_message': message,
    };
  }

  @override
  String toString() {
    return 'AvatarMessage{avatar_message_id: $id, avatar_message: $message}';
  }
}
