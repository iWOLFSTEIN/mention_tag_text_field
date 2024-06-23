import 'package:flutter/material.dart';
import 'package:mention_tag_text_field/mention_tag_text_field.dart';

class EnvironmentVariableExample extends StatefulWidget {
  const EnvironmentVariableExample({super.key});

  @override
  State<EnvironmentVariableExample> createState() =>
      _EnvironmentVariableExampleState();
}

class _EnvironmentVariableExampleState
    extends State<EnvironmentVariableExample> {
  final _controller = MentionTagTextEditingController();
  final variable = 'secret';
  final suggestion = {'id': 1234, 'value': 'secret'};
  String? mentionValue;

  @override
  void initState() {
    super.initState();
    _controller.text = "Text has {{secret}}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
          child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (mentionValue != null)
              Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      _controller.addMention(
                          label: variable,
                          data: suggestion,
                          stylingWidget:
                              EnvironmentVariableSpan(suggestion: suggestion));
                    },
                    child: Text(variable),
                  )
                ],
              ),
            const SizedBox(
              height: 32.0,
            ),
            MentionTagTextFormField(
              controller: _controller,
              initialMentions: [
                (
                  '{{$variable}}',
                  suggestion,
                  EnvironmentVariableSpan(suggestion: suggestion)
                )
              ],
              onMention: onMention,
              mentionTagDecoration: const MentionTagDecoration(
                mentionStart: ['{'],
                mentionBreak: "",
                maxWords: 1,
                allowDecrement: false,
                allowEmbedding: true,
                showMentionStartSymbol: false,
              ),
            )
          ],
        ),
      )),
    );
  }

  void onMention(String? mention) {
    mentionValue = mention;
    setState(() {});
  }
}

class EnvironmentVariableSpan extends StatelessWidget {
  const EnvironmentVariableSpan({super.key, required this.suggestion});

  final Map<String, dynamic> suggestion;

  @override
  Widget build(BuildContext context) {
    return Text(
      "{{${suggestion['value']}}}",
      style: const TextStyle(color: Colors.blue, fontSize: 14),
    );
  }
}
