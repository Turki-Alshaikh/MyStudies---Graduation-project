import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../calendar/data/models/reminder.dart';

part 'reminder_state.dart';

class ReminderCubit extends Cubit<ReminderState> {
  ReminderCubit() : super(ReminderState(reminders: const []));

  void addReminder(Reminder reminder, {required String eventTitle, String? courseId}) {
    final reminders = List<Reminder>.from(state.reminders);
    reminders.add(reminder);
    emit(ReminderState(reminders: reminders));
  }

  void removeReminder(String reminderId) {
    final reminders = state.reminders.where((r) => r.id != reminderId).toList();
    emit(ReminderState(reminders: reminders));
  }

  void updateReminder(Reminder updated, {required String eventTitle, String? courseId}) {
    final reminders = state.reminders
        .map((r) => r.id == updated.id ? updated : r)
        .toList();
    emit(ReminderState(reminders: reminders));
  }

  List<Reminder> getRemindersForEvent(String eventId) {
    return state.reminders.where((r) => r.eventId == eventId).toList();
  }

  /// Remove all reminders for a specific event
  void removeRemindersForEvent(String eventId) {
    final updatedReminders = state.reminders
        .where((r) => r.eventId != eventId)
        .toList();
    emit(ReminderState(reminders: updatedReminders));
  }
}
