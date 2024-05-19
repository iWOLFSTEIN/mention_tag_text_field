import 'package:flutter/material.dart';
import 'package:mention_tag_text_field/src/constants.dart';
import 'package:mention_tag_text_field/src/mention_tag_data.dart';
import 'package:mention_tag_text_field/src/mention_tag_decoration.dart';
import 'package:mention_tag_text_field/src/string_extensions.dart';

class MentionTagTextEditingController extends TextEditingController {
  final List<MentionTagElement> _mentions = [];

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

    if (!mentionTagDecoration.allowDecrement) {
      final textPart = super.text.substring(0, indexCursor);
      final indexPosition = textPart.countChar(Constants.mentionEscape);
      _mentions.insert(indexPosition, mentionTagElement);
    } else {
      _mentions.add(mentionTagElement);
    }

    String _ = !mentionTagDecoration.allowDecrement
        ? _replaceLastSubstringWithEscaping(indexCursor, mentionInput!)
        : _replaceLastSubstring(indexCursor, label);
  }

  String _replaceLastSubstringWithEscaping(
      int indexCursor, String replacement) {
    String mentionStartSymbol = _replaceLastSubstring(
        indexCursor, Constants.mentionEscape,
        allowDecrement: false);
    selection =
        TextSelection.collapsed(offset: indexCursor - replacement.length + 2);
    return mentionStartSymbol;
  }

  String _replaceLastSubstring(int indexCursor, String replacement,
      {bool allowDecrement = true}) {
    if (super.text.length == 1) {
      final String mentionStartSymbol = super.text;
      super.text = !allowDecrement
          ? "$replacement${mentionTagDecoration.mentionBreak}"
          : "$text$replacement${mentionTagDecoration.mentionBreak}";

      _temp = super.text;
      return mentionStartSymbol;
    }

    var indexMentionStart = _getIndexFromMentionStart(indexCursor, super.text);
    indexMentionStart = indexCursor - indexMentionStart;
    final String mentionStartSymbol = super.text[indexMentionStart - 1];

    super.text = super.text.replaceRange(
        !allowDecrement ? indexMentionStart - 1 : indexMentionStart,
        indexCursor,
        "$replacement${mentionTagDecoration.mentionBreak}");

    _temp = super.text;

    return mentionStartSymbol;
  }

  int _getIndexFromMentionStart(int indexCursor, String value) {
    final mentionStartPattern =
        RegExp(mentionTagDecoration.mentionStart.join('|'));
    var indexMentionStart =
        value.substring(0, indexCursor).reversed.indexOf(mentionStartPattern);
    return indexMentionStart;
  }

  String? _getMention(String value) {
    final indexCursor = selection.base.offset;

    var indexMentionEnd = value
        .substring(0, indexCursor)
        .reversed
        .indexOf(mentionTagDecoration.mentionEnd);

    var indexMentionStart = _getIndexFromMentionStart(indexCursor, value);

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
    mentionInput = mention;

    if (value.length < _temp.length) {
      _updadeMentions(value);
    }

    _temp = value;
  }

  void _updadeMentions(String value) {
    final indexCursor = selection.base.offset;

    if (mentionTagDecoration.allowDecrement) {
      if (indexCursor - 1 < 0) return;
      if (value[indexCursor - 1] != Constants.mentionEscape) return;
    }

    int mentionsCount = value.countChar(Constants.mentionEscape);
    if (mentionsCount == _mentions.length) return;

    final textPart = super.text.substring(0, indexCursor);
    mentionsCount = textPart.countChar(Constants.mentionEscape);
    _mentions.removeAt(mentionsCount);
  }

  // void _updateAllMentions(String value) {
  //   final List<String> allMentions =
  //       _extractMentions(value, splitBy: Constants.mentionEscape);
  //   final List<MentionTagElement> mentionsCopy = List.from(_mentions);

  //   for (final mention in mentionsCopy) {
  //     if (!allMentions.contains(mention.mention)) {
  //       _mentions.removeWhere(
  //           (mentionData) => mentionData.mention == mention.mention);
  //     }
  //   }
  // }

  // List<String> _extractMentions(String value, {String? splitBy}) {
  //   List<String> words = value.split(splitBy ?? mentionTagDecoration.mentionEnd);
  //   List<String> allMentions = [];

  //   for (final mentionStart in mentionTagDecoration.mentionStart) {
  //     for (String word in words) {
  //       if (word.startsWith(mentionStart)) {
  //         allMentions.add(word);
  //       }
  //     }
  //   }
  //   return allMentions;
  // }

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
              mention.mention,
              style: mentionTagDecoration.mentionTextStyle,
            ),
          );
        }
        return TextSpan(text: e, style: style);
      }).toList(),
    );

    // List<InlineSpan> children = [];

    // final mentionStartPattern = mentionTagDecoration.mentionStart.join('|');
    // final mentionRegex = RegExp('(?:$mentionStartPattern)\\S+');

    // var textParts = super.text.split(mentionRegex);
    // var mentionMatches = mentionRegex.allMatches(super.text);

    // for (var i = 0; i < super.textParts.length; i++) {
    //   children.add(TextSpan(text: textParts[i], style: style));
    //   if (i < mentionMatches.length) {
    //     final mention = mentionMatches.elementAt(i).group(0);
    //     bool isMentioned = _mentions.firstWhereOrNull((element) {
    //           return element.mention == mention;
    //         }) !=
    //         null;
    //     children.add(TextSpan(
    //         text: mention,
    //         style:
    //             isMentioned ? mentionTagDecoration.mentionTextStyle : style));
    //   }
    // }

    // return TextSpan(style: style, children: children);
  }
}
