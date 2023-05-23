import 'package:flutter/material.dart';
import 'package:shorts_clone/screens/video_display.dart';
import 'package:shorts_clone/screens/video_playing.dart';

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
        
        primarySwatch: Colors.blue,
      ),
      home: const VideoDisplayScreen(),
    );
  }
}


