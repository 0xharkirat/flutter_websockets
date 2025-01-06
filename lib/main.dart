import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  static String socketUrl() {
    if (kIsWeb) {
      return "ws://localhost:8080";
    } else
    if (Platform.isAndroid) {
      return "ws://10.0.2.2:8080";
    } else {
      return "ws://localhost:8080";
    }
  }
  final _channel = WebSocketChannel.connect(
    Uri.parse(socketUrl()),
  );
  int _counter = 0;

  void _sendMessage() {
    _channel.sink.add("increment");
  }

  void _resetCounter() {
    _channel.sink.add("reset");
  }

  @override
  void initState() {
    
    super.initState();
    _listen(); // Listen to the WebSocket channel
  }

  void _listen() {
    _channel.stream.listen((data) {
      final message = jsonDecode(data as String);
      log('Received message: $message');
      if (message['type'] == 'counter') {
        setState(() {
          _counter = message['value'];
        });
      }
    });
  }

  @override
  void dispose() {
    _channel.sink.close();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text("You have pushed the button this many times:"),
            const SizedBox(height: 24),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.bodyLarge,
            ),

            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _resetCounter,
              child: const Text('Reset'),
            ),

          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _sendMessage,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
