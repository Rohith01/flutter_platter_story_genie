import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:story_genie/services/models/story_model.dart';
import 'package:story_genie/services/models/user_profile_model.dart';
import 'package:story_genie/services/repository/firebase_db_repository.dart';
import 'package:story_genie/services/repository/generate_story_repository.dart';

part 'generate_story_state.dart';

class GenerateStoryCubit extends Cubit<GenerateStoryState> {
  GenerateStoryCubit(this.generateStoryRepository, this.firebaseDBRepository)
    : super(GenerateStoryInitial());
  final GenerateStoryRepository generateStoryRepository;
  final FirebaseDBRepository firebaseDBRepository;

  void generateStory({required Map<String, String> promptDetails}) async {
    emit(GenerateStoryLoading());
    try {
      final UserProfile user = await firebaseDBRepository.getUserProfile();
      promptDetails['age'] =
          '${int.parse(user.kidsAge ?? '3') - 1} - ${int.parse(user.kidsAge ?? '3') + 1}';

      final data = await generateStoryRepository.generateStory(promptDetails);
      firebaseDBRepository.addStories(data);
      emit(GenerateStoryLoaded(story: data));
    } catch (e) {
      if (e == SocketException) {
        emit(GenerateStoryNoInternetError());
      }
      debugPrint('error:: $e');
      emit(GenerateStoryError(message: e.toString()));
    }
  }

  void selectCharacter(String selectedCharacter) {
    emit(GenerateStoryLoading());
    try {
      emit(SelectCharacterLoaded(character: selectedCharacter));
    } catch (e) {
      debugPrint('error:: $e');
      emit(GenerateStoryError(message: e.toString()));
    }
  }

  void selectLanguage(String selectedLangauge) {
    emit(GenerateStoryLoading());
    try {
      emit(SelectLanguageLoaded(language: selectedLangauge));
    } catch (e) {
      debugPrint('error:: $e');
      emit(GenerateStoryError(message: e.toString()));
    }
  }
}
