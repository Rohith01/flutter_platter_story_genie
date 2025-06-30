extension StringExtension on String {
  ///Capitalize first character of the string. eg: "first step" to "First step"
  String get toCapitalized =>
      length > 0 ? '${this[0].toUpperCase()}${substring(1).toLowerCase()}' : '';

  ///Capitalize first character of each word in the string. eg: "first step" to "First Step"
  String get toTitleCase => replaceAll(
    RegExp(' +'),
    ' ',
  ).split(' ').map((str) => str.toCapitalized).join(' ');
}
