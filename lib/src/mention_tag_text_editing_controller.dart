import 'package:flutter/material.dart';
import 'package:mention_tag_text_field/src/constants.dart';
import 'package:mention_tag_text_field/src/mention_tag_data.dart';
import 'package:mention_tag_text_field/src/mention_tag_decoration.dart';
import 'package:mention_tag_text_field/src/string_extensions.dart';

class MentionTagTextEditingController extends TextEditingController {
  final List<MentionTagElement> _mentions = [];

  /// Get the list of data associated with you mentions, if no data was given the mention labels will be returned.
  List get mentions =>
      List.from(_mentions.map((mention) => mention.data ?? mention.mention));

  @override
  String get text {
    final List<MentionTagElement> tempList = List.from(_mentions);
    return super.text.replaceAllMapped(
        Constants.mentionEscape, (match) => tempList.removeAt(0).mention);
  }

  late MentionTagDecoration mentionTagDecoration;
  void Function(String?)? onMention;

  set initialMentions(List<(String, Object?)> value) {
    for (final mentionTuple in value) {
      if (!super.text.contains(mentionTuple.$1)) return;
      super.text =
          super.text.replaceFirst(mentionTuple.$1, Constants.mentionEscape);
      _temp = super.text;
      _mentions.add(
          MentionTagElement(mention: mentionTuple.$1, data: mentionTuple.$2));
    }
  }

  String _temp = '';
  String? mentionInput;

  /// Mention or Tag label, this label will be visible in the Text Field.
  ///
  /// The data associated with this mention. You can get this data using _controller.mentions property.
  /// If you do not pass any data, a list of the mention labels will be returned.
  /// If you skip some values, mentioned labels will be added in those places.
  void addMention({
    required String label,
    Object? data,
  }) {
    final indexCursor = selection.base.offset;
    final mentionSymbol = mentionInput!.first;

    final MentionTagElement mentionTagElement =
        MentionTagElement(mention: "$mentionSymbol$label", data: data);

    final textPart = super.text.substring(0, indexCursor);
    final indexPosition = textPart.countChar(Constants.mentionEscape);
    _mentions.insert(indexPosition, mentionTagElement);

    _replaceLastSubstringWithEscaping(indexCursor, mentionInput!);
  }

  void _replaceLastSubstringWithEscaping(int indexCursor, String replacement) {
    try {
      _replaceLastSubstring(indexCursor, Constants.mentionEscape,
          allowDecrement: false);
      selection =
          TextSelection.collapsed(offset: indexCursor - replacement.length + 2);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void _replaceLastSubstring(int indexCursor, String replacement,
      {bool allowDecrement = true}) {
    if (super.text.length == 1) {
      super.text = !allowDecrement
          ? "$replacement${mentionTagDecoration.mentionBreak}"
          : "$text$replacement${mentionTagDecoration.mentionBreak}";
      _temp = super.text;
      return;
    }

    var indexMentionStart = _getIndexFromMentionStart(indexCursor, super.text);
    indexMentionStart = indexCursor - indexMentionStart;

    super.text = super.text.replaceRange(
        !allowDecrement ? indexMentionStart - 1 : indexMentionStart,
        indexCursor,
        "$replacement${mentionTagDecoration.mentionBreak}");
    _temp = super.text;
  }

  int _getIndexFromMentionStart(int indexCursor, String value) {
    final mentionStartPattern =
        RegExp(mentionTagDecoration.mentionStart.join('|'));
    var indexMentionStart =
        value.substring(0, indexCursor).reversed.indexOf(mentionStartPattern);
    return indexMentionStart;
  }

  bool _isMentionEmbeddedOrDistinct(String value, int indexMentionStart) {
    final indexMentionStartSymbol = indexMentionStart - 1;
    if (indexMentionStartSymbol == 0) return true;
    if (mentionTagDecoration.allowEmbedding) return true;
    if (value[indexMentionStartSymbol - 1] == Constants.mentionEscape) {
      return true;
    }
    if (value[indexMentionStartSymbol - 1] == ' ') return true;
    return false;
  }

  String? _getMention(String value) {
    final indexCursor = selection.base.offset;

    final indexMentionFromStart = _getIndexFromMentionStart(indexCursor, value);

    if (mentionTagDecoration.maxWords != null) {
      final indexMentionEnd = value
          .substring(0, indexCursor)
          .reversed
          .indexOfNthSpace(mentionTagDecoration.maxWords!);

      if (indexMentionEnd != -1 && indexMentionEnd < indexMentionFromStart) {
        return null;
      }
    }

    if (indexMentionFromStart != -1) {
      if (value.length == 1) return value.first;

      final indexMentionStart = indexCursor - indexMentionFromStart;

      if (!_isMentionEmbeddedOrDistinct(value, indexMentionStart)) return null;

      if (indexMentionStart != -1 &&
          indexMentionStart >= 0 &&
          indexMentionStart <= indexCursor) {
        return value.substring(indexMentionStart - 1, indexCursor);
      }
    }
    return null;
  }

  void _updateOnMention(String? mention) {
    onMention!(mention);
    mentionInput = mention;
  }

  void onChanged(String value) async {
    if (onMention == null) return;
    String? mention = _getMention(value);
    _updateOnMention(mention);

    if (value.length < _temp.length) {
      _updadeMentions(value);
    }

    _temp = value;
  }

  void _checkAndUpdateOnMention(
    String value,
    int mentionsCountTillCursor,
    int indexCursor,
  ) {
    if (_temp.length - value.length != 1) return;
    if (!mentionTagDecoration.allowDecrement) return;
    if (mentionsCountTillCursor < 1) return;

    var indexMentionEscape = value
        .substring(0, indexCursor)
        .reversed
        .indexOf(Constants.mentionEscape);
    indexMentionEscape = indexCursor - indexMentionEscape - 1;
    final isCursorAtMention = (indexCursor - indexMentionEscape) == 1;
    if (isCursorAtMention) {
      final MentionTagElement cursorMention =
          _mentions[mentionsCountTillCursor - 1];
      _updateOnMention(cursorMention.mention);
    }
  }

  void _updadeMentions(String value) {
    try {
      final indexCursor = selection.base.offset;

      final mentionsCount = value.countChar(Constants.mentionEscape);
      final textPart = super.text.substring(0, indexCursor);
      final mentionsCountTillCursor =
          textPart.countChar(Constants.mentionEscape);

      _checkAndUpdateOnMention(value, mentionsCountTillCursor, indexCursor);
      if (mentionsCount == _mentions.length) return;

      final MentionTagElement removedMention =
          _mentions.removeAt(mentionsCountTillCursor);

      if (mentionTagDecoration.allowDecrement &&
          _temp.length - value.length == 1) {
        final replacementText = removedMention.mention
            .substring(0, removedMention.mention.length - 1);
        super.text =
            super.text.replaceRange(indexCursor, indexCursor, replacementText);
        selection = TextSelection.collapsed(
            offset: indexCursor + removedMention.mention.length - 1);
        _updateOnMention(replacementText);
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  TextSpan buildTextSpan(
      {required BuildContext context,
      TextStyle? style,
      required bool withComposing}) {
    final regexp = RegExp(
        '(?=${Constants.mentionEscape})|(?<=${Constants.mentionEscape})');
    final res = super.text.split(regexp);
    final List tempList = List.from(_mentions);

    return TextSpan(
      style: style,
      children: res.map((e) {
        if (e == Constants.mentionEscape) {
          final mention = tempList.removeAt(0);

          return WidgetSpan(
            child: Text(
              mentionTagDecoration.showMentionStartSymbol
                  ? mention.mention
                  : (mention.mention as String)
                      .removeMentionStart(mentionTagDecoration.mentionStart),
              style: mentionTagDecoration.mentionTextStyle,
            ),
          );
        }
        return TextSpan(text: e, style: style);
      }).toList(),
    );
  }
}
