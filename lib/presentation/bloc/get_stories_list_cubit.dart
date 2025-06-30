import 'dart:async';

import 'package:algoliasearch/algoliasearch.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:story_genie/core/constants.dart';
import 'package:story_genie/services/models/story_model.dart';
import 'package:story_genie/services/repository/firebase_db_repository.dart';
import 'package:story_genie/services/repository/search_stories_repository.dart';

part 'get_stories_list_state.dart';

class GetStoriesListCubit extends Cubit<GetStoriesListState> {
  GetStoriesListCubit(this.firebaseDBRepository, this.searchStoriesRepository)
    : super(GetStoriesListInitial());
  final FirebaseDBRepository firebaseDBRepository;
  final SearchStoriesRepository searchStoriesRepository;

  void getStories(String character, AiStory? lastDoc) async {
    emit(GetStoriesListLoading());
    try {
      final data = await firebaseDBRepository.getStories(character, lastDoc);

      emit(
        GetStoriesListLoaded(
          stories: data,
          isLastPage: data.length < kMaxDocsPerCallLimit,
        ),
      );
    } on TimeoutException {
      emit(
        const GetStoriesListError(
          message: 'Please check if you have active internet connection.',
        ),
      );
    } catch (e) {
      emit(GetStoriesListError(message: e.toString()));
    }
  }

  void getEditorStories() async {
    emit(GetEditorStoriesListLoading());
    try {
      final data = await firebaseDBRepository.getEditorStories();
      emit(GetEditorStoriesListLoaded(stories: data));
    } on TimeoutException {
      emit(
        const GetStoriesListError(
          message: 'Please check if you have active internet connection.',
        ),
      );
    } catch (e) {
      emit(GetStoriesListError(message: e.toString()));
    }
  }

  void searchStories(String searchTerm) async {
    emit(GetStoriesListLoading());
    try {
      final data = await searchStoriesRepository.searchStories(searchTerm);
      emit(
        GetStoriesListLoaded(
          stories: data,
          isLastPage: data.length < kMaxDocsPerCallLimit,
        ),
      );
    } on UnreachableHostsException {
      emit(const GetStoriesListError(message: 'No Internet Connection'));
    } catch (e) {
      if (e.toString() == 'SocketException') {
        emit(const GetStoriesListError(message: 'No Internet Connection'));
      } else {
        emit(GetStoriesListError(message: e.toString()));
      }
    }
  }

  void getMyStories(AiStory? lastDoc) async {
    emit(GetStoriesListLoading());
    try {
      final data = await firebaseDBRepository.getMyStories(lastDoc);
      emit(
        GetStoriesListLoaded(
          stories: data,
          isLastPage: data.length < kMaxDocsPerCallLimit,
        ),
      );
    } on TimeoutException {
      emit(
        const GetStoriesListError(
          message: 'Please check if you have active internet connection.',
        ),
      );
    } catch (e) {
      emit(GetStoriesListError(message: e.toString()));
    }
  }

  void getSavedStories(AiStory? lastDoc) async {
    emit(GetStoriesListLoading());
    try {
      final data = await firebaseDBRepository.getSavedStories(lastDoc);
      emit(
        GetStoriesListLoaded(
          stories: data,
          isLastPage: data.length < kMaxDocsPerCallLimit,
        ),
      );
    } on TimeoutException {
      emit(
        const GetStoriesListError(
          message: 'Please check if you have active internet connection.',
        ),
      );
    } catch (e) {
      emit(GetStoriesListError(message: e.toString()));
    }
  }
}
