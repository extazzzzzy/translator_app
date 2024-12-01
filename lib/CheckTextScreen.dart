import 'package:flutter/material.dart';

class CheckTextScreen extends StatelessWidget {
  final String recognizedText;

  CheckTextScreen({required this.recognizedText});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Распознанный текст')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          recognizedText.isEmpty ? 'Текст не распознан' : recognizedText,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
