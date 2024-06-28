import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(ChatApp());
}

class ChatApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ChatScreen(),
    );
  }
}

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Widget> _messages = [];

  Stream<String> _sendMessage(String message) async* {
    if (message.isEmpty) return;

    setState(() {
      _messages.add(Text("You: $message"));
    });

    _controller.clear();

    final response = await http.post(
      Uri.parse('https://ollama.vinzlab.com/api/generate'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'model': 'gemma:2b', 'prompt': message}),
    );

    if (response.statusCode == 200) {
      final lines = LineSplitter.split(response.body);
      for (final line in lines) {
        final decoded = json.decode(line);
        final token = decoded['response'] as String;
        yield token;
      }
    } else {
      yield "Error ${response.statusCode}";
    }
  }

  void _handleSendMessage() {
    final message = _controller.text;
    if (message.isNotEmpty) {
      final responseStream = _sendMessage(message);
      setState(() {
        _messages.add(
          StreamBuilder<String>(
            stream: responseStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text("Error: ${snapshot.error}");
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
      appBar: AppBar(title: Text('ChatGPT Chatbox')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) => _messages[index],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      labelText: 'Send a message',
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
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
