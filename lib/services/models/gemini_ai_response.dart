import 'dart:convert';

class GeminiAiResponse {
  GeminiAiResponse({
    required this.candidates,
    required this.usageMetadata,
    required this.modelVersion,
    required this.responseId,
  });

  factory GeminiAiResponse.fromRawJson(String str) =>
      GeminiAiResponse.fromJson(json.decode(str));

  factory GeminiAiResponse.fromJson(Map<String, dynamic> json) =>
      GeminiAiResponse(
        candidates: List<Candidate>.from(
          json['candidates'].map((x) => Candidate.fromJson(x)),
        ),
        usageMetadata: UsageMetadata.fromJson(json['usageMetadata']),
        modelVersion: json['modelVersion'],
        responseId: json['responseId'],
      );
  List<Candidate> candidates;
  UsageMetadata usageMetadata;
  String modelVersion;
  String responseId;

  String toRawJson() => json.encode(toJson());

  Map<String, dynamic> toJson() => {
    'candidates': List<dynamic>.from(candidates.map((x) => x.toJson())),
    'usageMetadata': usageMetadata.toJson(),
    'modelVersion': modelVersion,
    'responseId': responseId,
  };
}

class Candidate {
  Candidate({
    required this.content,
    required this.finishReason,
    required this.avgLogprobs,
  });

  factory Candidate.fromRawJson(String str) =>
      Candidate.fromJson(json.decode(str));

  factory Candidate.fromJson(Map<String, dynamic> json) => Candidate(
    content: Content.fromJson(json['content']),
    finishReason: json['finishReason'],
    avgLogprobs: json['avgLogprobs']?.toDouble(),
  );
  Content content;
  String finishReason;
  double avgLogprobs;

  String toRawJson() => json.encode(toJson());

  Map<String, dynamic> toJson() => {
    'content': content.toJson(),
    'finishReason': finishReason,
    'avgLogprobs': avgLogprobs,
  };
}

class Content {
  Content({required this.parts, required this.role});

  factory Content.fromRawJson(String str) => Content.fromJson(json.decode(str));

  factory Content.fromJson(Map<String, dynamic> json) => Content(
    parts: List<Part>.from(json['parts'].map((x) => Part.fromJson(x))),
    role: json['role'],
  );
  List<Part> parts;
  String role;

  String toRawJson() => json.encode(toJson());

  Map<String, dynamic> toJson() => {
    'parts': List<dynamic>.from(parts.map((x) => x.toJson())),
    'role': role,
  };
}

class Part {
  Part({required this.text});

  factory Part.fromRawJson(String str) => Part.fromJson(json.decode(str));

  factory Part.fromJson(Map<String, dynamic> json) => Part(text: json['text']);
  String text;

  String toRawJson() => json.encode(toJson());

  Map<String, dynamic> toJson() => {'text': text};
}

class UsageMetadata {
  UsageMetadata({
    required this.promptTokenCount,
    required this.candidatesTokenCount,
    required this.totalTokenCount,
    required this.promptTokensDetails,
    required this.candidatesTokensDetails,
  });

  factory UsageMetadata.fromRawJson(String str) =>
      UsageMetadata.fromJson(json.decode(str));

  factory UsageMetadata.fromJson(Map<String, dynamic> json) => UsageMetadata(
    promptTokenCount: json['promptTokenCount'],
    candidatesTokenCount: json['candidatesTokenCount'],
    totalTokenCount: json['totalTokenCount'],
    promptTokensDetails: List<TokensDetail>.from(
      json['promptTokensDetails'].map((x) => TokensDetail.fromJson(x)),
    ),
    candidatesTokensDetails: List<TokensDetail>.from(
      json['candidatesTokensDetails'].map((x) => TokensDetail.fromJson(x)),
    ),
  );
  int promptTokenCount;
  int candidatesTokenCount;
  int totalTokenCount;
  List<TokensDetail> promptTokensDetails;
  List<TokensDetail> candidatesTokensDetails;

  String toRawJson() => json.encode(toJson());

  Map<String, dynamic> toJson() => {
    'promptTokenCount': promptTokenCount,
    'candidatesTokenCount': candidatesTokenCount,
    'totalTokenCount': totalTokenCount,
    'promptTokensDetails': List<dynamic>.from(
      promptTokensDetails.map((x) => x.toJson()),
    ),
    'candidatesTokensDetails': List<dynamic>.from(
      candidatesTokensDetails.map((x) => x.toJson()),
    ),
  };
}

class TokensDetail {
  TokensDetail({required this.modality, required this.tokenCount});

  factory TokensDetail.fromRawJson(String str) =>
      TokensDetail.fromJson(json.decode(str));

  factory TokensDetail.fromJson(Map<String, dynamic> json) =>
      TokensDetail(modality: json['modality'], tokenCount: json['tokenCount']);
  String modality;
  int tokenCount;

  String toRawJson() => json.encode(toJson());

  Map<String, dynamic> toJson() => {
    'modality': modality,
    'tokenCount': tokenCount,
  };
}
