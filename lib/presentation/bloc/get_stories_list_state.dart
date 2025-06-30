part of 'get_stories_list_cubit.dart';

abstract class GetStoriesListState extends Equatable {
  const GetStoriesListState();

  @override
  List<Object> get props => [];
}

class GetStoriesListInitial extends GetStoriesListState {}

class GetStoriesListLoading extends GetStoriesListState {}

class GetEditorStoriesListLoading extends GetStoriesListState {}

class GetStoriesListLoaded extends GetStoriesListState {
  const GetStoriesListLoaded({required this.stories, required this.isLastPage});
  final List<AiStory> stories;
  final bool isLastPage;
  @override
  List<Object> get props => [stories, isLastPage];
}

class GetEditorStoriesListLoaded extends GetStoriesListState {
  const GetEditorStoriesListLoaded({required this.stories});
  final List<AiStory> stories;
  @override
  List<Object> get props => [stories];
}

class GetStoriesListError extends GetStoriesListState {
  const GetStoriesListError({required this.message});
  final String message;

  @override
  List<Object> get props => [message];
}
