import 'dart:ui';
import 'dart:ui' as ui;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:mention_tag_text_field/src/mention_tag_decoration.dart';
import 'package:mention_tag_text_field/src/mention_tag_text_editing_controller.dart';

class MentionTagTextField extends TextField {
  MentionTagTextField({
    super.key,
    MentionTagTextEditingController? controller,
    this.onMention,
    this.onMentionStateChanged,
    this.mentionTagDecoration = const MentionTagDecoration(),
    super.focusNode,
    super.undoController,
    super.decoration = const InputDecoration(),
    TextInputType? keyboardType,
    super.textInputAction,
    super.textCapitalization = TextCapitalization.none,
    super.style,
    super.strutStyle,
    super.textAlign = TextAlign.start,
    super.textAlignVertical,
    super.textDirection,
    super.readOnly = false,
    @Deprecated(
      'Use `contextMenuBuilder` instead. '
      'This feature was deprecated after v3.3.0-0.5.pre.',
    )
    super.toolbarOptions,
    super.showCursor,
    super.autofocus = false,
    super.statesController,
    super.obscuringCharacter = '•',
    super.obscureText = false,
    super.autocorrect = true,
    SmartDashesType? smartDashesType,
    SmartQuotesType? smartQuotesType,
    super.enableSuggestions = true,
    super.maxLines = 1,
    super.minLines,
    super.expands = false,
    super.maxLength,
    super.maxLengthEnforcement,
    void Function(String)? onChanged,
    super.onEditingComplete,
    super.onSubmitted,
    super.onAppPrivateCommand,
    super.inputFormatters,
    super.enabled,
    super.cursorWidth = 2.0,
    super.cursorHeight,
    super.cursorRadius,
    super.cursorOpacityAnimates,
    super.cursorColor,
    super.cursorErrorColor,
    super.selectionHeightStyle = ui.BoxHeightStyle.tight,
    super.selectionWidthStyle = ui.BoxWidthStyle.tight,
    super.keyboardAppearance,
    super.scrollPadding = const EdgeInsets.all(20.0),
    super.dragStartBehavior = DragStartBehavior.start,
    bool? enableInteractiveSelection,
    super.selectionControls,
    super.onTap,
    super.onTapAlwaysCalled = false,
    super.onTapOutside,
    super.mouseCursor,
    super.buildCounter,
    super.scrollController,
    super.scrollPhysics,
    super.autofillHints = const <String>[],
    super.contentInsertionConfiguration,
    super.clipBehavior = Clip.hardEdge,
    super.restorationId,
    super.scribbleEnabled = true,
    super.enableIMEPersonalizedLearning = true,
    super.contextMenuBuilder = _defaultContextMenuBuilder,
    super.canRequestFocus = true,
    super.spellCheckConfiguration,
    super.magnifierConfiguration,
  }) : super(
            controller: controller,
            onChanged: (value) {
              try {
                controller?.onChanged(value);
                onChanged?.call(value);
              } catch (e, s) {
                debugPrint(e.toString());
                debugPrint(s.toString());
              }
            }) {
    _setControllerProperties(controller);
  }

  /// Provides the mention value whenever a mention is initiated, indicated by the mention start character
  /// (e.g., "@"), and ends when a space character is encountered.
  final void Function(String?)? onMention;

  /// Returns true when mention or tag has started and false when mention or tag is ended
  final Function(bool)? onMentionStateChanged;

  /// Indicates the decoration related to mentions or tags
  final MentionTagDecoration mentionTagDecoration;

  static Widget _defaultContextMenuBuilder(
      BuildContext context, EditableTextState editableTextState) {
    return AdaptiveTextSelectionToolbar.editableText(
      editableTextState: editableTextState,
    );
  }

  void _setControllerProperties(
      MentionTagTextEditingController? mentionController) {
    if (mentionController == null) return;
    mentionController.mentionTagDecoration = mentionTagDecoration;
    mentionController.onMentionStateChanged = onMentionStateChanged;
    mentionController.onMention = onMention;
  }
}
