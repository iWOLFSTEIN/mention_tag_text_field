extension StringExtensions on String {
  /// Get the first character in the string
  String get first {
    if (isNotEmpty) {
      return substring(0, 1);
    } else {
      return '';
    }
  }

  /// Get the last character in the string
  String get last {
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
