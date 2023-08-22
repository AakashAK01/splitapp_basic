import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';

class SpeechToTextScreen extends StatefulWidget {
  const SpeechToTextScreen({super.key});

  @override
  State<SpeechToTextScreen> createState() => _SpeechToTextScreenState();
}

class _SpeechToTextScreenState extends State<SpeechToTextScreen> {
  SpeechToText stt = SpeechToText();

  var text = 'hold the button to speak';

  var isListening = false;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.sizeOf(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple,
        title: const Text('Speech to text'),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(size.width / 16),
        child: SingleChildScrollView(
          reverse: true,
          physics: const BouncingScrollPhysics(),
          child: Container(
            alignment: Alignment.center,
            width: size.width,
            height: size.height * .7,
            color: Colors.grey,
            child: Text(text),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: GestureDetector(
        onTapDown: (details) async {
          if (!isListening) {
            var available = await stt.initialize();
            if (available) {
              setState(() {
                isListening = true;
                stt.listen(
                  onResult: (result) {
                    setState(() {
                      text = result.recognizedWords;
                    });
                  },
                );
              });
            }
          }
        },
        onTapUp: (details) {
          setState(() {
            isListening = false;
          });
          stt.stop();
        },
        child: CircleAvatar(
          backgroundColor: isListening ? Colors.grey : Colors.purple,
          radius: 32,
          child: const Icon(
            Icons.mic,
            size: 30,
          ),
        ),
      ),
    );
  }
}
