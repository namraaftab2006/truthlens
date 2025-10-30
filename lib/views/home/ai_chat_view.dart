import 'package:flutter/material.dart';
import '../../utils/constants.dart';

class AiChatView extends StatelessWidget {
  const AiChatView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constants.backgroundColor,
      appBar: AppBar(
        backgroundColor: Constants.accentColor,
        title: const Text('AI Chatbot', style: TextStyle(color: Colors.brown)),
        centerTitle: true,
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Text(
            '🤖 AI Chatbot feature coming soon!\n\n'
                'Here you’ll be able to ask news-related questions or summaries.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18),
          ),
        ),
      ),
    );
  }
}
