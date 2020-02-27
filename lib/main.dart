import 'package:flutter/material.dart';
import 'package:chaitu/chat.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Colors.white,
        cursorColor: Colors.white,
        dividerColor: Colors.white
      ),
      color: Colors.white,
      debugShowCheckedModeBanner: false,
      title: 'Chat App',
      home: Chat(),
    );
  }
}
