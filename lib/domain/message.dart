class Message {
  String content;
  int recipientId;
  String dateCreated;
  int senderId;

  Message({
    required this.content,
    required this.recipientId,
    required this.dateCreated,
    required this.senderId
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      content: json['content'],
      recipientId: json['recipientId'],
      dateCreated: json['dateCreated'],
      senderId: json['senderId']
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'recipientId': recipientId,
      'dateCreated': dateCreated,
      'senderId': senderId,
    };
  }
}
