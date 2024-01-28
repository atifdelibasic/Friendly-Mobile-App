import 'package:timeago/timeago.dart' as timeago;

String calculateTimeAgo(String createdAtString) {
  final createdAt = DateTime.parse(createdAtString);
  final now = DateTime.now();
  final difference = now.difference(createdAt);
  return timeago.format(now.subtract(difference));
}