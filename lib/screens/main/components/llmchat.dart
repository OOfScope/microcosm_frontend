import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:http/http.dart' as http;
import 'header.dart';

class LLMChatApp extends StatelessWidget {
  const LLMChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Header(title: 'Ollama Chat',),
      ),
      body:     MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.teal,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const LLMChat(),
    )
    );

  }
}

class LLMChat extends StatelessWidget {
  const LLMChat({super.key});

  @override
  Widget build(BuildContext context) {
    // Pass the server URL here
    const String serverUrl = 'https://ollama.vinzlab.com/api/generate';

    return const Scaffold(
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: LLMChatWidget(serverUrl: serverUrl),
      ),
    );
  }
}

class LLMChatWidget extends StatefulWidget {

  const LLMChatWidget({super.key, required this.serverUrl});
  final String serverUrl;

  @override
  _LLMChatWidgetState createState() => _LLMChatWidgetState();
}

class _LLMChatWidgetState extends State<LLMChatWidget> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = <Map<String, String>>[];
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _sendMessage(String message) async {
    setState(() {
      _messages.add(<String, String>{'role': 'user', 'content': message});
    });

    String serverResponse = '';
    bool done = false;
    final Uri url = Uri.parse(widget.serverUrl);
    final String body = jsonEncode(<String, String>{'model': 'gemma:2b', 'prompt': message});

    // Add an initial empty response box for the server response
    setState(() {
      _messages.add(<String, String>{'role': 'server', 'content': ''});
    });

    while (!done) {
      final http.Response response = await http.post(url, body: body, headers: <String, String>{'Content-Type': 'application/json'});

      if (response.statusCode == 200) {
        final List<String> lines = response.body.split('\n');
        for (final String line in lines) {
          if (line.isNotEmpty) {
            final data = jsonDecode(line);
            serverResponse += _cleanResponse(data['response'] as String); // Clean response from Unicode characters
            done = data['done'] as bool; // Update done as bool
            setState(() {
              _messages[_messages.length - 1]['content'] = serverResponse;
            });
          }
        }
      } else {
        setState(() {
          _messages[_messages.length - 1]['content'] = 'Error: ${response.reasonPhrase}';
        });
        break;
      }

      // Ensure the latest message is visible by scrolling to the bottom
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  String _cleanResponse(String response) {
    // Remove or replace Unicode characters as needed
    return response.replaceAll(RegExp(r'[^\x00-\x7F]'), '');
  }

  void _handleSubmitted(String text) {
    if (text.isNotEmpty) {
      _sendMessage(text);
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            itemCount: _messages.length,
            itemBuilder: (BuildContext context, int index) {
              final Map<String, String> message = _messages[index];
              return ListTile(
                title: Align(
                  alignment: message['role'] == 'user'
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                    decoration: BoxDecoration(
                      color: message['role'] == 'user'
                          ? Colors.teal[100]
                          : Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: MarkdownBody(
                      data: message['content']!,
                      styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
                        p: Theme.of(context).textTheme.bodyText1,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            children: <Widget>[
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Enter your message',
                  ),
                  onSubmitted: (_) => _handleSubmitted(_controller.text), // Handle sending message on Enter
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  _handleSubmitted(_controller.text); // Send message on button press
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20), // Larger button size
                  textStyle: const TextStyle(fontSize: 18),
                ),
                child: const Text('Send'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}