import 'package:flutter/material.dart';

class MentionTagDecoration {
  const MentionTagDecoration({
    this.mentionStart = const ['@', '#'],
    this.mentionBreak = ' ',
    this.isSingleWordMention = true,
    this.mentionEnd = ' ',
    this.mentionTextStyle =
        const TextStyle(color: Colors.blue, fontWeight: FontWeight.w600),
  });

  /// Indicates the start point of mention or tag
  final List<String> mentionStart;

  /// Default character to place after mention.
  /// In case of tags if you don't want any space you can set this empty string.
  final String mentionBreak;

  /// TextStyle of mentioned or tagged text
  final TextStyle mentionTextStyle;

  /// Default value is true and is useful for hashtags or usernames
  /// mentionEnd property is used along with this to recognise single word mention or tags
  final bool isSingleWordMention;

  /// Only used when isSingleWordMention set to true.
  /// This property is used along with this to recognise single word mention or tags
  final String mentionEnd;
}
