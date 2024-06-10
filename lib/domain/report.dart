class Report {
  final int id;
  final int userId;
  final int? postId;
  final int? commentId;
  final int reportReasonId;
  final String additionalComment;

  Report({
    required this.id,
    required this.userId,
    this.postId,
    this.commentId,
    required this.reportReasonId,
    required this.additionalComment,
  });

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      id: json['id'],
      userId: json['userId'],
      postId: json['postId'],
      commentId: json['commentId'],
      reportReasonId: json['reportReasonId'],
      additionalComment: json['additionalComment'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'postId': postId,
      'commentId': commentId,
      'reportReasonId': reportReasonId,
      'additionalComment': additionalComment,
    };
  }
}
