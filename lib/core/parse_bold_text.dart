import 'package:flutter/material.dart';

///Converters any text between *gibbrish* to Bold
List<TextSpan> parseBoldText(String text, TextStyle textStyle) {
  final List<TextSpan> spans = [];
  final regex = RegExp(r'(\*[^*]+\*)');
  final matches = regex.allMatches(text);

  int currentIndex = 0;

  for (final match in matches) {
    // Add normal text before the match
    if (match.start > currentIndex) {
      spans.add(
        TextSpan(
          text: text.substring(currentIndex, match.start),
          style: textStyle,
        ),
      );
    }

    // Extract the bold text without the asterisks
    final boldText = match.group(0)!.replaceAll('*', '');
    spans.add(
      TextSpan(
        text: boldText,
        style: textStyle.copyWith(fontWeight: FontWeight.bold),
      ),
    );

    currentIndex = match.end;
  }

  // Add any remaining text after the last match
  if (currentIndex < text.length) {
    spans.add(TextSpan(text: text.substring(currentIndex), style: textStyle));
  }

  return spans;
}
