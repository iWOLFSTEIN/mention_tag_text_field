extension StringExtensions on String {
  /// Get the last character in the string
  String get lastCharacter {
    if (isNotEmpty) {
      return substring(length - 1);
    } else {
      return '';
    }
  }

  /// Remove mention start symbols from the beginning of the string
  String removeMentionStart(List<String> mentionStartSymbols) {
    for (final symbol in mentionStartSymbols) {
      if (startsWith(symbol)) {
        return substring(symbol.length);
      }
    }
    return this;
  }
}
