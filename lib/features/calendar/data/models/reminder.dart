class Reminder {
  final String id;
  final String eventId;
  final String message;
  final DateTime triggerTime;
  final DateTime createdAt;
  final bool isTriggered;

  Reminder({
    required this.id,
    required this.eventId,
    required this.message,
    required this.triggerTime,
    required this.createdAt,
    this.isTriggered = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'eventId': eventId,
      'message': message,
      'triggerTime': triggerTime.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'isTriggered': isTriggered,
    };
  }

  factory Reminder.fromJson(Map<String, dynamic> json) {
    return Reminder(
      id: json['id'],
      eventId: json['eventId'],
      message: json['message'],
      triggerTime: DateTime.parse(json['triggerTime']),
      createdAt: DateTime.parse(json['createdAt']),
      isTriggered: json['isTriggered'] ?? false,
    );
  }

  Reminder copyWith({
    String? id,
    String? eventId,
    String? message,
    DateTime? triggerTime,
    DateTime? createdAt,
    bool? isTriggered,
  }) {
    return Reminder(
      id: id ?? this.id,
      eventId: eventId ?? this.eventId,
      message: message ?? this.message,
      triggerTime: triggerTime ?? this.triggerTime,
      createdAt: createdAt ?? this.createdAt,
      isTriggered: isTriggered ?? this.isTriggered,
    );
  }
}
