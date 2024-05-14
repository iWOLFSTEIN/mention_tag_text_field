import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mention_tag_text_field/mention_tag_text_field.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MentionTagTextFieldExample(),
    );
  }
}

class MentionTagTextFieldExample extends StatefulWidget {
  const MentionTagTextFieldExample({
    super.key,
  });

  @override
  State<MentionTagTextFieldExample> createState() =>
      _MentionTagTextFieldExampleState();
}

class _MentionTagTextFieldExampleState
    extends State<MentionTagTextFieldExample> {
  final MentionTagTextEditingController _controller =
      MentionTagTextEditingController();

  String mentionValue = '';
  bool isMentionStarted = false;
  late List<String> usernames = [
    for (int i = 0; i < 10; i++) generateRandomUserName()
  ];

  String? allMentions;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              if (isMentionStarted)
                suggestions()
              else
                const Expanded(child: SizedBox()),
              if (allMentions != null) selectedMentions(),
              const SizedBox(
                height: 16,
              ),
              mentionField(),
              const SizedBox(
                height: 16,
              ),
              getAllMentionsButton()
            ],
          ),
        ),
      ),
    );
  }

  Container getAllMentionsButton() {
    return Container(
      color: Colors.blue,
      width: double.infinity,
      height: 50,
      child: TextButton(
        onPressed: () {
          allMentions =
              _controller.mentions.map((e) => e.mention).toList().join(' ');
          setState(() {});
        },
        child: const Text(
          'Get All Mentions',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  MentionTagTextField mentionField() {
    return MentionTagTextField(
      controller: _controller,
      onMention: (value) {
        if (value == null) return;
        mentionValue = value;
        setState(() {});
      },
      onMentionStateChanged: (state) {
        isMentionStarted = state;
        setState(() {});
      },
      mentionTagDecoration: const MentionTagDecoration(
          mentionBreak: ' ',
          mentionStart: ['@', '#'],
          mentionTextStyle: TextStyle(color: Colors.blue)),
    );
  }

  Container selectedMentions() {
    return Container(
      color: Colors.orange,
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      child: Text(
        allMentions!,
        style: const TextStyle(color: Colors.white),
      ),
    );
  }

  Expanded suggestions() {
    return Expanded(
        child: ListView.builder(
            itemCount: usernames.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  _controller
                      .addMention(MentionTagData(mention: usernames[index]));
                  isMentionStarted = false;
                  setState(() {});
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(usernames[index]),
                ),
              );
            }));
  }

  String generateRandomUserName({int length = 6}) {
    const letters = 'abcdefghijklmnopqrstuvwxyz';
    const digits = '0123456789';
    const specials = '_-';

    const allCharacters = '$letters$digits$specials';

    final random = Random();
    return List.generate(
            length, (_) => allCharacters[random.nextInt(allCharacters.length)])
        .join();
  }
}
