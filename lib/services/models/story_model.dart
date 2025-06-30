import 'dart:convert';

class AiStory {
  AiStory({
    this.id,
    required this.story,
    required this.title,
    required this.character,
    required this.featuredImagePrompt,
    required this.featureImage,
    required this.userName,
    this.isSaved = false,
    required this.savedBy,
    required this.createdAt,
  });

  factory AiStory.fromRawJson(String str) => AiStory.fromJson(json.decode(str));

  factory AiStory.fromJson(Map<String, dynamic> json) => AiStory(
    id: json['id'],
    story: json['story'],
    title: json['title'],
    character: json['character'],
    featuredImagePrompt: json['feature_image_prompt'],
    featureImage: json['feature_image'],
    userName: json['username'],
    isSaved: json['isSaved'],
    createdAt: json['createdAt'],
    savedBy: List<String>.from(json['savedBy'].map((x) => x)),
  );
  String? id;
  String story;

  String title;
  String character;
  String featuredImagePrompt;
  String featureImage;
  String userName;
  bool? isSaved;
  List<String> savedBy;
  String createdAt;

  String toRawJson() => json.encode(toJson());

  Map<String, dynamic> toJson() => {
    'id': id,
    'story': story,
    'title': title,
    'character': character,
    'feature_image_prompt': featuredImagePrompt,
    'feature_image': featureImage,
    'username': userName,
    'isSaved': isSaved,
    'savedBy': List<dynamic>.from(savedBy.map((x) => x)),
    'createdAt': createdAt,
  };
}
