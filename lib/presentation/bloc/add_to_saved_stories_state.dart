part of 'add_to_saved_stories_cubit.dart';

abstract class AddToSavedStoriesState extends Equatable {
  const AddToSavedStoriesState();

  @override
  List<Object> get props => [];
}

class AddToSavedStoriesInitial extends AddToSavedStoriesState {}

class AddToSavedStoriesLoading extends AddToSavedStoriesState {}

class SavedStoryLoaded extends AddToSavedStoriesState {}

class RemovedSavedStoryLoaded extends AddToSavedStoriesState {}

class AddToSavedStoriesError extends AddToSavedStoriesState {
  const AddToSavedStoriesError({required this.message});
  final String message;

  @override
  List<Object> get props => [message];
}
