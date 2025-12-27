class Room {
  final String id;
  final String roomNumber;

  Room({required this.id, required this.roomNumber});

  Map<String, dynamic> toJson() {
    return {'id': id, 'roomNumber': roomNumber};
  }

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(id: json['id'], roomNumber: json['roomNumber']);
  }

  String getDisplayName() {
    return 'Room $roomNumber';
  }
}
