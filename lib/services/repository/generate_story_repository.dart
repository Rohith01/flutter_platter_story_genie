import 'dart:io';
import 'dart:math';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:story_genie/core/constants.dart';
import 'package:story_genie/core/featured_image_picker.dart';
import 'package:story_genie/services/models/gemini_ai_response.dart';
import 'package:story_genie/services/models/story_model.dart';

class GenerateStoryRepositoryImpl implements GenerateStoryRepository {
  GenerateStoryRepositoryImpl(this.dio, this.firebaseAuth, this.connectivity);
  final Dio dio;
  final FirebaseAuth firebaseAuth;
  final Connectivity connectivity;

  @override
  Future<AiStory> generateStory(Map<String, String?> storyFormData) async {
    final connectionResult = await connectivity.checkConnectivity();
    if (connectionResult.contains(ConnectivityResult.mobile) ||
        connectionResult.contains(ConnectivityResult.wifi) ||
        connectionResult.contains(ConnectivityResult.ethernet)) {
      final String age = storyFormData['age'] ?? '2-8';
      final String character = storyFormData['character'] ?? 'animal';
      final String language = storyFormData['language'] ?? 'English';
      final String additionalInfo =
          storyFormData['additionalInfo'] == null ||
                  storyFormData['additionalInfo']!.isEmpty
              ? 'kindness'
              : storyFormData['additionalInfo']!;

      final response = await dio.post(
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent',

        queryParameters: {'key': kGeminiApiKey},
        options: Options(contentType: Headers.jsonContentType),
        data: {
          'contents': [
            {
              'parts': [
                {
                  'text':
                      'I need a short story for kids aged $age. The story should be around 300-500 words and feature a friendly ${character.toLowerCase() == 'animal' ? kPromptAnimalCharacter[Random().nextInt(8)] : character} character who learns a valuable lesson about ${kPromptMoralTheme[Random().nextInt(5)]}. The story should subtly weave in elements of Indian culture. The tone should be whimsical and positive, with a clear beginning, middle, and end. The story should be in $language. Also add elements such as $additionalInfo. In addition to the story, please provide a featured image in cartoon style which looks attractive to kids, that would perfectly represent the story and cartoon style which looks attractive to kids. Your output should be in text format with entire story in between <story> tag, title for the story in <title> tag and image in between <image> tag.',
                },
              ],
            },
          ],
        },
      );
      final aiStoryBlock =
          GeminiAiResponse.fromJson(
            response.data,
          ).candidates.first.content.parts.first.text;

      final story = AiStory(
        title: getTextValue(
          startTag: '<title>',
          endTag: '</title>',
          aiStoryBlock: aiStoryBlock,
        ),
        story: getTextValue(
          startTag: '<story>',
          endTag: '</story>',
          aiStoryBlock: aiStoryBlock,
        ),
        character: character,
        featureImage: pickFeaturedImage(character),
        featuredImagePrompt: getTextValue(
          startTag: '<image>',
          endTag: '</image>',
          aiStoryBlock: aiStoryBlock,
        ),
        userName: firebaseAuth.currentUser!.displayName ?? 'Anonymous',
        isSaved: false,
        savedBy: [],
        createdAt: DateTime.now().toIso8601String(),
      );

      return story;
    } else {
      throw SocketException;
    }
  }
}

abstract class GenerateStoryRepository {
  Future<AiStory> generateStory(Map<String, String> storyFormData);
}

String getTextValue({
  required String startTag,
  required String endTag,
  required String aiStoryBlock,
}) {
  final startIndex = aiStoryBlock.indexOf(startTag);
  final endIndex = aiStoryBlock.indexOf(endTag, startIndex + startTag.length);
  return aiStoryBlock.substring(startIndex + 7, endIndex).trim();
}
