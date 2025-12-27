import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../schedule/presentation/cubits/schedule_cubit.dart';
import '../../../schedule/presentation/cubits/schedule_state.dart';
import '../cubit/resources_cubit.dart';
import '../widgets/resource_course_section.dart';
import '../widgets/resources_empty_state.dart';

import '../../../../core/constants/app_spacing.dart';

class ResourcesScreen extends StatelessWidget {
  const ResourcesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final cubit = ResourcesCubit();
        final scheduleCubit = context.read<ScheduleCubit>();
        final state = scheduleCubit.state;
        final courses = state is ScheduleSuccess
            ? state.courses
            : scheduleCubit.courses;
        cubit.loadResources(courses);
        return cubit;
      },
      child: const _ResourcesView(),
    );
  }
}

class _ResourcesView extends StatelessWidget {
  const _ResourcesView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resources'),
        backgroundColor: Colors.transparent,
        elevation: AppSpacing.elevationNone,
      ),
      body: BlocBuilder<ResourcesCubit, ResourcesState>(
        builder: (context, state) {
          if (state is ResourcesEmpty) {
            return const ResourcesEmptyState();
          }

          if (state is ResourcesLoaded) {
            return ListView.builder(
              padding: AppSpacing.paddingLG,
              itemCount: state.courses.length,
              itemBuilder: (context, index) {
                final course = state.courses[index];
                final resources = state.courseResources[course.id] ?? [];
                return ResourceCourseSection(
                  course: course,
                  resources: resources,
                );
              },
            );
          }

          return const ResourcesEmptyState();
        },
      ),
    );
  }
}
