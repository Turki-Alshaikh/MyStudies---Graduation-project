class WeekDay {
  final int id;
  final String name;

  WeekDay({required this.id, required this.name});

  static final List<WeekDay> days = [
    WeekDay(id: 1, name: 'Monday'),
    WeekDay(id: 2, name: 'Tuesday'),
    WeekDay(id: 3, name: 'Wednesday'),
    WeekDay(id: 4, name: 'Thursday'),
    WeekDay(id: 5, name: 'Friday'),
    WeekDay(id: 6, name: 'Saturday'),
    WeekDay(id: 7, name: 'Sunday'),
  ];

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }

  factory WeekDay.fromJson(Map<String, dynamic> json) {
    return WeekDay(id: json['id'], name: json['name']);
  }

  static WeekDay getById(int id) {
    return days.firstWhere((day) => day.id == id);
  }
}
