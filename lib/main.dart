import 'package:flutter/material.dart';
import 'package:translator/FavoriteWordsScreen.dart';
import 'package:translator/HomeScreen.dart';
import 'package:translator/GamingScreen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Translator',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: GamingScreen(),
    );
  }
}
