import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const ChatApp());
}

class ChatApp extends StatelessWidget {
  const ChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: ChatScreen(),
    );
  }
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Widget> _messages = <Widget>[];

  Stream<String> _sendMessage(String message) async* {
    if (message.isEmpty) {
      return;
    }

    setState(() {
      _messages.add(Text('You: $message'));
    });

    _controller.clear();

    final http.Response response = await http.post(
      Uri.parse('https://ollama.vinzlab.com/api/generate'),
      headers: <String, String>{'Content-Type': 'application/json'},
      body:
          json.encode(<String, String>{'model': 'gemma:2b', 'prompt': message}),
    );

    if (response.statusCode == 200) {
      final Iterable<String> lines = LineSplitter.split(response.body);
      for (final String line in lines) {
        final Map<String, dynamic> decoded =
            json.decode(line) as Map<String, dynamic>;
        final String token = decoded['response'] as String;
        if (kDebugMode) {
          print(token);
        }
        yield token;
      }
    } else {
      yield 'Error ${response.statusCode}';
    }
  }

  void _handleSendMessage() {
    final String message = _controller.text;
    if (message.isNotEmpty) {
      final Stream<String> responseStream = _sendMessage(message);
      setState(() {
        _messages.add(
          StreamBuilder<String>(
            stream: responseStream,
            builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else if (snapshot.hasData) {
                return MarkdownBody(data: snapshot.data!);
              } else {
                return Container();
              }
            },
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ChatGPT Chatbox')),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (BuildContext context, int index) =>
                  _messages[index],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      labelText: 'Send a message',
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _handleSendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
