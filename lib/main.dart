import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'features/calendar/presentation/cubits/reminder_cubit.dart';
import 'features/schedule/data/datasources/pdf_processing_service.dart';
import 'features/schedule/data/repos/schedule_repository_impl.dart';
import 'features/schedule/presentation/cubits/schedule_cubit.dart';
import 'features/settings/presentation/cubit/theme_cubit.dart';
import 'navigation/main_navigation.dart';

/// Main entry point of the MyStudies app
/// Initializes Flutter bindings and starts the app
void main() async {
  // Required for async operations before runApp
  WidgetsFlutterBinding.ensureInitialized();

  // Start the app
  runApp(MyStudiesApp());
}

class MyStudiesApp extends StatefulWidget {
  const MyStudiesApp({super.key});

  @override
  State<MyStudiesApp> createState() => _MyStudiesAppState();
}

class _MyStudiesAppState extends State<MyStudiesApp> {
  @override
  Widget build(BuildContext context) {
    // Create the schedule repository that handles PDF imports
    final scheduleRepository = ScheduleRepositoryImpl(PdfProcessingService());

    // Set up all state managers (Cubits) that the app needs
    return MultiBlocProvider(
      providers: [
        // Theme manager: handles dark/light mode
        BlocProvider(create: (_) => ThemeCubit()..load()),

        // Schedule manager: handles courses, events, and schedule imports
        BlocProvider(create: (_) => ScheduleCubit(repo: scheduleRepository)),

        // Reminders manager: handles event reminders
        BlocProvider(create: (_) => ReminderCubit()),
      ],
      child: BlocBuilder<ThemeCubit, bool>(
        builder: (context, isDarkMode) {
          final themeCubit = context.read<ThemeCubit>();

          return MaterialApp(
            title: 'MyStudies',
            theme: themeCubit.currentTheme,
            home: const MainNavigation(),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
