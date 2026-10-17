class AppNotificationItem {
  final int? id;
  final String title;
  final String message;
  final String type; // e.g. 'consumption_increase'
  final DateTime dateTime;
  final bool isRead;
  final String? payload;

  const AppNotificationItem({
    this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.dateTime,
    this.isRead = false,
    this.payload,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'type': type,
      'date_time': dateTime.toIso8601String(),
      'is_read': isRead ? 1 : 0,
      'payload': payload,
    };
  }

  factory AppNotificationItem.fromMap(Map<String, dynamic> map) {
    return AppNotificationItem(
      id: map['id'] as int?,
      title: map['title'] as String,
      message: map['message'] as String,
      type: map['type'] as String,
      dateTime: DateTime.parse(map['date_time'] as String),
      isRead: (map['is_read'] as int) == 1,
      payload: map['payload'] as String?,
    );
  }
}
