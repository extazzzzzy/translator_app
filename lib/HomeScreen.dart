import 'dart:convert';
import 'package:translator/selectTest.dart';
import 'gameScreen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'background_video.dart';
import 'package:flutter/services.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String sourceLanguage = 'rus_Cyrl';
  String targetLanguage = 'mancy_Cyrl';

  String sourceLanguageText = 'Русский';
  String targetLanguageText = 'Мансийский';
  String sourceText = 'Привет';
  String targetText = '';

  void changeLanguage() {
    if (sourceLanguageText == 'Русский') {
      sourceLanguageText = 'Мансийский';
      targetLanguageText = 'Русский';

      sourceLanguage = 'mancy_Cyrl';
      targetLanguage = 'rus_Cyrl';

      var temp = sourceText;
      sourceText = targetText;
      targetText = temp;
    }
    else {
      sourceLanguageText = 'Русский';
      targetLanguageText = 'Мансийский';

      sourceLanguage = 'rus_Cyrl';
      targetLanguage = 'mancy_Cyrl';

      var temp = sourceText;
      sourceText = targetText;
      targetText = temp;
    }
  }

  void clearText()
  {
    sourceText = '';
    targetText = '';
  }

  void copyText(String sourceOrTargetText) {
    if (sourceOrTargetText == 'source') {
      Clipboard.setData(ClipboardData(text: sourceText));
    }
    else {
      Clipboard.setData(ClipboardData(text: targetText));
    }
  }

  Future<void> translateText() async {
    final String url = 'http://91.198.71.199:7012/translator';

    final Map<String, String> requestBody = {
      "text": sourceText,
      "sourceLanguage": sourceLanguage,
      "targetLanguage": targetLanguage,
    };

    final response = await http.post(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
      body: json.encode(requestBody),
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(utf8.decode(response.bodyBytes));
      setState(() {
        targetText = responseData['translatedText'];
      });
    }
    else {
      print('Error: ${response.statusCode}');
    }
  }
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            flexibleSpace: Container(
              alignment: Alignment.center,
              padding: EdgeInsets.fromLTRB(0, 40, 0, 20),
              decoration: BoxDecoration(
                color: Colors.grey,
              ),
              child: Text(
                'Translator',
                style: TextStyle(
                  fontSize: 30,
                  fontFamily: 'Times New Roman',
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                overflow: TextOverflow.visible,
              ),
            ),
            elevation: 5.0,
            shadowColor: Colors.black,
            toolbarHeight: 70,
            actions: [
              Container(
                margin: EdgeInsets.only(top: 5,right: 20),
                child: IconButton(
                  onPressed: () async {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => selectTestScreen()),
                    );
                  },
                  color: Colors.white,
                  icon: Icon(Icons.videogame_asset_rounded),
                  iconSize: 50,
                ),
              )
            ],
        ),
      body: Column(
        children: [
          //BackgroundVideo(),
          Container(
            margin: EdgeInsets.only(top: 20, left: 10, right: 10),
            decoration: BoxDecoration(
              color: Color.fromRGBO(13, 191, 28, 1.0),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        sourceLanguageText,
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(right: 5.0),
                  child: IconButton(
                    onPressed: () {
                      setState(() {
                        changeLanguage();
                      });
                    },
                    color: Colors.white,
                    icon: Icon(Icons.compare_arrows_rounded),
                    iconSize: 40,
                  ),
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        targetLanguageText,
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 200,
            width: 390,
            margin: EdgeInsets.only(top: 15, right: 10, left: 10),
            decoration: BoxDecoration(
              color: Color.fromRGBO(77, 91, 129, 1.0),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  spreadRadius: 3,
                  blurRadius: 5,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Stack(
              children: [
                Container(
                  margin: EdgeInsets.fromLTRB(10,18,10,0),
                  padding: EdgeInsets.all(10),
                  child: Text(
                    sourceText.isEmpty ? 'Введите текст' : sourceText,
                    style: TextStyle(
                      fontSize: 20,
                      fontFamily: 'Times New Roman',
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: IconButton(
                    onPressed: () {
                      setState(() {
                        clearText();
                      });
                    },
                    icon: Icon(Icons.close, color: Colors.white),
                  ),
                ),
                Positioned(
                  bottom: 10,
                  right: 10,
                  child: IconButton(
                    onPressed: () {
                      copyText('source');
                    },
                    icon: Icon(Icons.copy, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 200,
            width: 390,
            margin: EdgeInsets.only(top: 15, right: 10, left: 10),
            decoration: BoxDecoration(
              color: Color.fromRGBO(37, 49, 73, 1.0),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  spreadRadius: 3,
                  blurRadius: 5,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Stack(
              children: [
                Container(
                  margin: EdgeInsets.fromLTRB(10,18,10,0),
                  padding: EdgeInsets.all(10),
                  child: Text(
                    targetText.isEmpty ? "Перевод" : targetText,
                    style: TextStyle(
                      fontSize: 20,
                      fontFamily: 'Times New Roman',
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: IconButton(
                    onPressed: () {
                      copyText('target');
                    },
                    icon: Icon(Icons.copy, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: translateText,
              child: Text(
                'Перевести',
              ),
          ),
        ],
      ),
    );
  }
}