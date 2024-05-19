import 'package:flutter/material.dart';

@immutable
class MentionTagElement {
  final String mention;
  final Object? data;
  const MentionTagElement({required this.mention, this.data});
}
