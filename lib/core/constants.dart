import 'package:flutter/material.dart';
import 'package:story_genie/services/models/story_character.dart';

Color kPrimary = const Color(0xfff1faee);
Color kSecondary = const Color(0xffa8dadc);
Color kSecondaryDark = const Color(0xff457b9d);
Color kPrimaryText = const Color(0xff1d3557);
Color kPrimaryDark = const Color(0xff1d3557);
Color kPrimaryTextDark = const Color(0xfff1faee);
Color kAccentColor = const Color(0xffe63946);

List<Color> pastelColorsList = [
  const Color(0xffFCF6BD),
  const Color(0xffD0F4DE),
  const Color(0xffA9DEF9),
  const Color(0xffE4C1F9),
];

List<Color> colorsList = [
  const Color(0xffFFCA3A),
  const Color(0xff8AC926),
  const Color(0xff1982C4),
  const Color(0xff6A4C93),
];

List<String> greetings = [
  'Have a super-excellent ',
  'Have a smashing ',
  'Have a kickass ',
  'Have a primo ',
  'Have an ace ',
  "Have a cat's meow ",
  'Have a tiptop ',
  'Have an exceptional ',
  'Have a superb ',
  'Have a first-rate ',
  'Have a fantastic ',
  'Have a luminous ',
  'Have a first-class ',
  'Have an impeccable ',
  'Have a cool ',
];

//TODO:: Replace API keys
const kWebRecaptchaSiteKey = 'please replace with your recaptcha site key';
const kGoogleSigninClientId =
    'please replace with your google signin client id';
const kGeminiApiKey = 'please replace with your gemini api key';
const kAlgoliaAppId = 'please replace with your Algolia app id';
const kAlgoliApiKey = 'please replace with your Algolia API key';

const kMaxDocsPerCallLimit = 20;

List<StoryCharacter> characters = [
  StoryCharacter(
    characterName: 'Animal',
    characterImage: 'assets/image/story_characters/animal.jpg',
  ),
  StoryCharacter(
    characterName: 'Boy',
    characterImage: 'assets/image/story_characters/boy.jpg',
  ),
  StoryCharacter(
    characterName: 'Girl',
    characterImage: 'assets/image/story_characters/girl.jpg',
  ),
  StoryCharacter(
    characterName: 'Princess',
    characterImage: 'assets/image/story_characters/princess.jpg',
  ),
  StoryCharacter(
    characterName: 'Superhero',
    characterImage: 'assets/image/story_characters/superhero.jpg',
  ),
  StoryCharacter(
    characterName: 'Robot',
    characterImage: 'assets/image/story_characters/robot.jpg',
  ),
  StoryCharacter(
    characterName: 'Ghost',
    characterImage: 'assets/image/story_characters/ghost.jpg',
  ),
];

List<String> kPromptMoralTheme = [
  'Honesty and Integrity',
  'Kindness and Compassion',
  'Courage and Perseverance',
  'Responsibility and Hard Work',
  'Overcoming Challenges',
];
List<String> kPromptAnimalCharacter = [
  'Monkey',
  'Lion',
  'Cat',
  'Dog',
  'Elephant',
  'Rabbit',
  'Duck',
  'Animal',
];
List<String> kFeaturedAnimalImage = [
  'Monkey',
  'Lion',
  'Cat',
  'Dog',
  'Elephant',
  'Rabbit',
  'Duck',
  'Animal',
];
