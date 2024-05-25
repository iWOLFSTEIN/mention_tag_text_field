This package extends the capabilties of a normal TextField or TextFormField to enable mention or tagging.
<!-- <div style="display: flex; justify-content: center;">
  <div style="overflow: hidden; height: 600px;">
    <iframe allow="fullscreen;autoplay" allowfullscreen height="800" src="https://streamable.com/e/y3gaye?autoplay=1&muted=1&nocontrols=1" width="400" style="border:none; margin-top: -200px;"></iframe>
  </div>
</div> -->
<!-- [![SfUtS.gif](https://s10.gifyu.com/images/SfUtS.gif)](https://gifyu.com/image/SfUtS) -->
<div style="display: flex; justify-content: center;">
  <img src="https://s10.gifyu.com/images/SfUtS.gif" alt="Demo GIF" />
</div>



## Getting started

In your pubspec.yaml
```yaml
dependencies:
  mentionable_text_field: ^0.0.1
```

Import the package using
```dart
import 'package:mention_tag_text_field/mention_tag_text_field.dart';
```

## Usage

Define a MentionTagTextEditingController
```dart
final MentionTagTextEditingController _controller =
      MentionTagTextEditingController();
```

You can use MentionTagTextField just like you normal TextField. If you are using Form widget you can use MentionTagTextFormField.
```dart
 @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              if (mentionValue != null)
                suggestions() // Widget to show search results
              else
                const Expanded(child: SizedBox()),
              const SizedBox(
                height: 16,
              ),
              MentionTagTextField(
                controller: _controller,

                // onMention will return text when mention is triggered, otherwise it'll return null.
                onMention: (value) async {
                  mentionValue = value;
                  setState(() {});
                  await getUsersFromNetwork(); // Write your logic to get search results
                },
                mentionTagDecoration: MentionTagDecoration(
                    // Define list of symbols where mention will be triggered.
                    mentionStart: ['@', '#'],

                    // The character which will be inserted automatically after the mention.
                    mentionBreak: ' ',

                    // Enable removing mention decrementally instead of all at once.
                    allowDecrement: true,

                    // Represents if mention should be triggered if mention symbol is embedded in the text.
                    allowEmbedding: false,

                    // If mention symbol is visible or not with mentions in the textfield.
                    showMentionStartSymbol: false,

                    // Max words a mention can have, must be greater than 0 or null. Null means any number of words.
                    maxWords: null,

                    // TextStyle for mentions
                    mentionTextStyle: TextStyle(
                        color: Colors.blue,
                        backgroundColor: Colors.blue.shade50)),
                decoration: InputDecoration(
                    hintText: 'Write something...',
                    hintStyle: TextStyle(color: Colors.grey.shade400),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide.none),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 12.0)),
              )
            ],
          ),
        ),
      ),
    );
  }
```

You can also set the initial mentions if your initial text has mentions in it. First set the initial text,
```dart
@override
  void initState() {
    super.initState();
    _controller.text = "Hello @Emily Johnson ";
  }
```

Now set the intial mentions using initialMentions property. You must pass a list of tuples containing mention label and data associated with it. The mention label must have a mandatory mention start symbol for intial mentions.
```dart
MentionTagTextField(
      controller: _controller,
      initialMentions: const [
        ('@Emily Johnson', User(id: 1, name: 'Emily Johnson'))
      ],
      ...
)
``` 

You can set the mentions using _controller.addMention which takes a mention label and optional data associated with it.
```dart
 _controller.addMention(label: 'Emily Johnson', data: User(id: 0, name: 'Emily Johnson'));
```

Finally, you can get all the mentions data using _controller.mentions which returns the list of data passed to each mention. If no data was passed, list of mention labels will be returned.
```dart
final List mentions = _controller.mentions;
```

## Additional information
- **Contributing**: Contributions are welcome! Feel free to open issues or submit pull requests on [GitHub](https://github.com/iWOLFSTEIN/mention_tag_text_field).
- **Support & Feedback**: You can expect prompt responses and support from the package maintainers.