import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:story_genie/services/repository/firebase_db_repository.dart';

part 'add_to_saved_stories_state.dart';

class AddToSavedStoriesCubit extends Cubit<AddToSavedStoriesState> {
  AddToSavedStoriesCubit(this.firebaseDBRepository)
    : super(AddToSavedStoriesInitial());
  final FirebaseDBRepository firebaseDBRepository;

  void addToSavedStories({String? docId, bool? isEditorStory}) async {
    emit(AddToSavedStoriesLoading());
    try {
      await firebaseDBRepository.addToSavedStories(
        docId: docId,
        isEditorStory: isEditorStory ?? false,
      );
      emit(SavedStoryLoaded());
    } catch (e) {
      emit(AddToSavedStoriesError(message: e.toString()));
    }
  }

  void removeFromSavedStories({String? docId, bool? isEditorStory}) async {
    emit(AddToSavedStoriesLoading());
    try {
      await firebaseDBRepository.removeFromSavedStories(
        docId: docId,
        isEditorStory: isEditorStory ?? false,
      );
      emit(RemovedSavedStoryLoaded());
    } catch (e) {
      emit(AddToSavedStoriesError(message: e.toString()));
    }
  }
}
