import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:mention_tag_text_field/src/mention_tag_data.dart';
import 'package:mention_tag_text_field/src/mention_tag_decoration.dart';
import 'package:mention_tag_text_field/src/string_extensions.dart';

class MentionTagTextEditingController extends TextEditingController {
  List<MentionTagData> mentions = [];
  late MentionTagDecoration mentionTagDecoration;
  void Function(String?)? onMention;
  String _temp = '';

  void addMention(MentionTagData mentionData) {
    String mentionSymbol = _replaceLastSubstring(mentionData.mention);
    mentionData.mention = "$mentionSymbol${mentionData.mention}";

    mentions.add(mentionData);
  }

  String _replaceLastSubstring(String replacement) {
    if (text.length == 1) {
      text = text + replacement + mentionTagDecoration.mentionBreak;
      _temp = text;
      return text[0];
    }

    final indexCursor = selection.base.offset;
    var indexMentionStart = _getIndexMentionStart(indexCursor, text);
    indexMentionStart = indexCursor - indexMentionStart;

    text = text.replaceRange(indexMentionStart, indexCursor,
        "$replacement${mentionTagDecoration.mentionBreak}");

    _temp = text;

    return text[indexMentionStart - 1];
  }

  int _getIndexMentionStart(int indexCursor, String value) {
    final mentionStartPattern =
        RegExp(mentionTagDecoration.mentionStart.join('|'));
    var indexMentionStart = value
        .substring(0, indexCursor)
        .split('')
        .reversed
        .join()
        .indexOf(mentionStartPattern);
    return indexMentionStart;
  }

  String? _getMention(String value) {
    final indexCursor = selection.base.offset;

    var indexMentionEnd = value
        .substring(0, indexCursor)
        .split('')
        .reversed
        .join()
        .indexOf(mentionTagDecoration.mentionEnd);

    var indexMentionStart = _getIndexMentionStart(indexCursor, value);

    if (indexMentionEnd != -1 && indexMentionEnd < indexMentionStart) {
      return null;
    }

    if (indexMentionStart != -1) {
      if (value.length == 1) return value.first;

      indexMentionStart = indexCursor - indexMentionStart;

      if (indexMentionStart != -1 &&
          indexMentionStart >= 0 &&
          indexMentionStart <= indexCursor) {
        return value.substring(indexMentionStart - 1, indexCursor);
      }
    }
    return null;
  }

  void onChanged(String value) async {
    if (onMention == null) return;
    String? mention = _getMention(value);
    onMention!(mention);

    if (value.length < _temp.length) {
      _updateAllMentions(value);
    }

    _temp = value;
  }

  void _updateAllMentions(String text) {
    final List<String> allMentions = _extractMentions(text);
    final List<MentionTagData> mentionsCopy = List.from(mentions);

    for (final mention in mentionsCopy) {
      if (!allMentions.contains(mention.mention)) {
        mentions.removeWhere(
            (mentionData) => mentionData.mention == mention.mention);
      }
    }
  }

  List<String> _extractMentions(String text) {
    List<String> words = text.split(mentionTagDecoration.mentionEnd);
    List<String> mentions = [];

    for (final mentionStart in mentionTagDecoration.mentionStart) {
      for (String word in words) {
        if (word.startsWith(mentionStart)) {
          mentions.add(word);
        }
      }
    }
    return mentions;
  }

  @override
  TextSpan buildTextSpan(
      {required BuildContext context,
      TextStyle? style,
      required bool withComposing}) {
    List<InlineSpan> children = [];

    final mentionStartPattern = mentionTagDecoration.mentionStart.join('|');
    final mentionRegex = RegExp('(?:$mentionStartPattern)\\S+');

    var textParts = text.split(mentionRegex);
    var mentionMatches = mentionRegex.allMatches(text);

    for (var i = 0; i < textParts.length; i++) {
      children.add(TextSpan(text: textParts[i], style: style));
      if (i < mentionMatches.length) {
        final mention = mentionMatches.elementAt(i).group(0);
        bool isMentioned = mentions.firstWhereOrNull((element) {
              return element.mention == mention;
            }) !=
            null;
        children.add(TextSpan(
            text: mention,
            style:
                isMentioned ? mentionTagDecoration.mentionTextStyle : style));
      }
    }

    return TextSpan(style: style, children: children);
  }
}
