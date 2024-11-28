import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<void> translateText() async {
    // URL для запроса
    final String url = 'http://91.198.71.199:7012/translator'; // Замените на ваш URL

    // Тело запроса
    final Map<String, String> requestBody = {
      "text": "Паща о̄лэн. Наӈ ос хумус о̄лэ̄гын, я̄тил утум?",
      "sourceLanguage": "mancy_Cyrl",
      "targetLanguage": "rus_Cyrl",
    };

    // Отправка POST запроса
    final response = await http.post(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
      body: json.encode(requestBody),
    );

    // Проверка ответа
    if (response.statusCode == 200) {
      final responseData = json.decode(utf8.decode(response.bodyBytes));

      // Извлекаем переведённый текст
      final translatedText = responseData['translatedText'];

      // Выводим результат
      print('Translated Text: $translatedText');
    } else {
      // В случае ошибки
      print('Error: ${response.statusCode}');
    }
  }
  @override
  void initState() {
    super.initState();

    translateText();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(

    );
  }
}