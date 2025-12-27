part of 'reminder_cubit.dart';

class ReminderState extends Equatable {
  final List<Reminder> reminders;
  const ReminderState({required this.reminders});

  @override
  List<Object?> get props => [reminders];
}
