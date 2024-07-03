import 'dart:convert';
import 'dart:io';
import 'package:google_generative_ai/google_generative_ai.dart';

class ChatBotBackend {
  late GenerativeModel _model;
  late ChatSession _chat;

  ChatBotBackend() {
    _initializeChatBot();
  }

  Future<void> _initializeChatBot() async {
    final apiKey = Platform.environment['API_KEY'];
    if (apiKey == null) {
      print('No \$API_KEY environment variable');
      exit(1);
    }
    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: apiKey,
      generationConfig: GenerationConfig(maxOutputTokens: 100),
    );
    _chat = await _model.startChat(history: [
      Content.text('Hello, I have 2 dogs in my house.'),
      Content.model([TextPart('Great to meet you. What would you like to know?')]),
    ]);
  }

  Future<String> sendMessage(String message) async {
    var content = Content.text(message);
    var response = await _chat.sendMessage(content);
    return response.text ?? ''; // return an empty string if response.text is null
  }
}

void main() async {
  ChatBotBackend backend = ChatBotBackend();
  await Future.delayed(Duration(seconds: 1)); // wait for _initializeChatBot to complete
  String response = await backend.sendMessage('How many paws are in my house?');
  print(response);
}
