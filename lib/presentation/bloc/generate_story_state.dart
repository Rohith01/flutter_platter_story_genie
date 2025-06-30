part of 'generate_story_cubit.dart';

abstract class GenerateStoryState extends Equatable {
  const GenerateStoryState();

  @override
  List<Object> get props => [];
}

class GenerateStoryInitial extends GenerateStoryState {}

class GenerateStoryLoading extends GenerateStoryState {}

class GenerateStoryLoaded extends GenerateStoryState {
  const GenerateStoryLoaded({required this.story});
  final AiStory story;
  @override
  List<Object> get props => [story];
}

class SelectCharacterLoaded extends GenerateStoryState {
  const SelectCharacterLoaded({required this.character});
  final String character;
  @override
  List<Object> get props => [character];
}

class SelectLanguageLoaded extends GenerateStoryState {
  const SelectLanguageLoaded({required this.language});
  final String language;
  @override
  List<Object> get props => [language];
}

class GenerateStoryError extends GenerateStoryState {
  const GenerateStoryError({required this.message});
  final String message;

  @override
  List<Object> get props => [message];
}

class GenerateStoryNoInternetError extends GenerateStoryState {}
