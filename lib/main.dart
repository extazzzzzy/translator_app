import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:translator/FavoriteWordsScreen.dart';
import 'package:translator/HomeScreen.dart';
import 'package:translator/GamingScreen.dart';
import 'package:translator/HomeScreen.dart';

void main() async {
  await Supabase.initialize(
    url: 'https://etdsbdgjlxfwwjpheqao.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImV0ZHNiZGdqbHhmd3dqcGhlcWFvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzE4NjQxMTcsImV4cCI6MjA0NzQ0MDExN30.xII51KyqHikHlh8FqbYjMPuqm6nZtUYVgnF0znr5spg',
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Translator',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomeScreen(),
    );
  }
}
