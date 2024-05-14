import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:mention_tag_text_field/src/mention_tag_data.dart';
import 'package:mention_tag_text_field/src/mention_tag_decoration.dart';
import 'package:mention_tag_text_field/src/string_extensions.dart';

class MentionTagTextEditingController extends TextEditingController {
  List<MentionTagData> mentions = [];
  late MentionTagDecoration mentionTagDecoration;
  List<int> _mentionedTextRange = [];
  void Function(bool)? onMentionStateChanged;
  void Function(String?)? onMention;
  bool _isMentioned = false;
  bool _mentionHasStarted = false;
  String _temp = '';
  int _mentionStartIndex = -1;

  void addMention(MentionTagData mentionData) {
    String mentionSymbol = _replaceLastSubstring(mentionData.mention);
    mentionData.mention = "$mentionSymbol${mentionData.mention}";
    mentions.add(mentionData);
    _reset();
  }

  String _replaceLastSubstring(String replacement) {
    if (_mentionedTextRange.length == 1) {
      text = text + replacement + mentionTagDecoration.mentionBreak;
      _temp = text;
      return text[_mentionedTextRange.first];
    }

    text = text.replaceRange(
            _mentionedTextRange.first, _mentionedTextRange.last, replacement) +
        mentionTagDecoration.mentionBreak;
    _temp = text;
    return text[_mentionedTextRange.first - 1];
  }

  void onChanged(String value) async {
    _isMentioned = false;
    for (final mentionStart in mentionTagDecoration.mentionStart) {
      if (value.lastCharacter == mentionStart) {
        _isMentioned = true;
        break;
      }
    }

    if (mentionTagDecoration.isSingleWordMention) {
      if (value.lastCharacter == ' ') {
        if (onMentionStateChanged != null) {
          _reset();
        }
      }
    }

    if (value.length < _temp.length) {
      _mentionStartIndex = _findPreviousMentionIndex(value, _temp);
      _updateAllMentions(value);

      for (final mentionStart in mentionTagDecoration.mentionStart) {
        if (_temp.lastCharacter == mentionStart) {
          if (onMentionStateChanged != null) {
            _reset();
          }
          break;
        }
      }
    }

    _temp = value;

    if (_mentionHasStarted) {
      final mentionedText = _extractSubstring(value, _mentionStartIndex + 1);
      if (onMention != null) {
        onMention!(mentionedText);
      }
      _mentionedTextRange = _findSubstringIndices(value, mentionedText);
    } else {
      if (onMention != null) {
        onMention!(null);
      }
    }

    if (!_isMentioned) return;

    if (onMentionStateChanged != null) {
      onMentionStateChanged!(true);
    }

    _mentionHasStarted = true;
    _mentionStartIndex = value.length - 1;
    _mentionedTextRange = [_mentionStartIndex];
  }

  String _extractSubstring(String text, int startIndex) {
    int endIndex = text.indexOf(' ', startIndex);
    if (endIndex == -1) {
      return text.substring(startIndex);
    } else {
      return text.substring(startIndex, endIndex);
    }
  }

  int _findPreviousMentionIndex(String str1, String str2) {
    int minLength = str1.length < str2.length ? str1.length : str2.length;

    for (int i = 0; i < minLength; i++) {
      if (str1[i] != str2[i]) {
        for (int j = i - 1; j >= 0; j--) {
          for (final mentionStart in mentionTagDecoration.mentionStart) {
            if (str2[j] == mentionStart) {
              return j;
            }
          }
        }
        break;
      }
    }

    for (int j = str2.length - 1; j >= 0; j--) {
      for (final mentionStart in mentionTagDecoration.mentionStart) {
        if (str2[j] == mentionStart) {
          return j;
        }
      }
    }

    return -1;
  }

  void _reset() {
    _mentionHasStarted = false;
    onMentionStateChanged!(false);
  }

  void _updateAllMentions(String text) {
    final List<String> allMentions = _extractMentions(text);
    final List<MentionTagData> mentionsCopy = List.from(mentions);

    for (final mention in mentionsCopy) {
      if (!allMentions.contains(mention.mention)) {
        onMentionStateChanged!(true);
        _mentionHasStarted = true;
        mentions.removeWhere(
            (mentionData) => mentionData.mention == mention.mention);
      }
    }
  }

  List<String> _extractMentions(String text) {
    List<String> words = text.split(' ');
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

  List<int> _findSubstringIndices(String mainString, String subString) {
    int startIndex = mainString.indexOf(subString);
    int endIndex = startIndex + subString.length;
    return [startIndex, endIndex];
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
