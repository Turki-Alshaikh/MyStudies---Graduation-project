part of 'resources_cubit.dart';

abstract class ResourcesState extends Equatable {
  const ResourcesState();

  @override
  List<Object?> get props => [];
}

class ResourcesInitial extends ResourcesState {
  const ResourcesInitial();
}

class ResourcesEmpty extends ResourcesState {
  const ResourcesEmpty();
}

class ResourcesLoaded extends ResourcesState {
  final List<Course> courses;
  final Map<String, List<Resource>> courseResources;

  const ResourcesLoaded({required this.courses, required this.courseResources});

  @override
  List<Object?> get props => [courses, courseResources];
}
