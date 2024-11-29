import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late VideoPlayerController _controllerVideo;
  late AnimationController _controllerAnimation;
  late Animation<double> _rotationAnimation;
  bool _isTextVisible = true;

  bool isTranslating = false;

  @override
  void initState() {
    super.initState();
    _controllerVideo = VideoPlayerController.asset("src/design/material/background2.mp4")
      ..initialize().then((_) {
        setState(() {
          _controllerVideo.setLooping(true);
          _controllerVideo.setVolume(0);
          _controllerVideo.play();
        });
      });

    _controllerAnimation = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    );

    _rotationAnimation = Tween<double>(begin: 0, end: 2 * 3.14159265359).animate(
      CurvedAnimation(
        parent: _controllerAnimation,
        curve: Curves.easeOut,
      ),
    );
  }

  @override
  void dispose() {
    _controllerVideo.dispose();
    _controllerAnimation.dispose();
    super.dispose();
  }

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
    } else {
      sourceLanguageText = 'Русский';
      targetLanguageText = 'Мансийский';

      sourceLanguage = 'rus_Cyrl';
      targetLanguage = 'mancy_Cyrl';

      var temp = sourceText;
      sourceText = targetText;
      targetText = temp;
    }
  }

  void clearText() {
    sourceText = '';
    targetText = '';
  }

  void copyText(String sourceOrTargetText) {
    if (sourceOrTargetText == 'source') {
      Clipboard.setData(ClipboardData(text: sourceText));
    } else {
      Clipboard.setData(ClipboardData(text: targetText));
    }
  }

  void _updateTextVisibility() {
    setState(() {
      _isTextVisible = false;
    });
    Future.delayed(Duration(milliseconds: 500), () {
      setState(() {
        _isTextVisible = true;
      });
    });
  }

  Future<void> translateText() async {
    setState(() {
      isTranslating = true;
    });

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
    } else {
      print('Error: ${response.statusCode}');
    }

    setState(() {
      isTranslating = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: _controllerVideo.value.isInitialized
                ? VideoPlayer(_controllerVideo)
                : Center(child: CircularProgressIndicator()),
          ),
          Column(
            children: [
              AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                title: null,
                flexibleSpace: Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.only(top: 5, bottom: 5),
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(37, 49, 73, 0.6),
                    //borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        spreadRadius: 3,
                        blurRadius: 5,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Text(
                    'Translator',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        margin: EdgeInsets.only(top: 20, left: 10, right: 10),
                        decoration: BoxDecoration(
                          color: Color.fromRGBO(13, 191, 28, 0.8),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Color.fromRGBO(12, 152, 24, 1.0), width: 3.5),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  AnimatedOpacity(
                                    opacity: _isTextVisible ? 1.0 : 0.0,
                                    duration: Duration(milliseconds: 300),
                                    child: Text(
                                      sourceLanguageText,
                                      style: TextStyle(
                                        fontSize: 20,
                                        color: Colors.white,
                                      ),
                                    ),
                                  )

                                ],
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(right: 5.0),
                              child: AnimatedBuilder(
                                animation: _rotationAnimation,
                                builder: (context, child) {
                                  return Transform.rotate(
                                    angle: _rotationAnimation.value,
                                    child: IconButton(
                                      onPressed: isTranslating
                                          ? null
                                          : () {
                                        setState(() {
                                          _updateTextVisibility();
                                          Future.delayed(Duration(milliseconds: 500), () {
                                            setState(() {
                                              changeLanguage();
                                            });
                                          });
                                          _controllerAnimation.forward(from: 0);
                                        });
                                      },
                                      color: Colors.white,
                                      icon: Icon(Icons.compare_arrows_rounded),
                                      iconSize: 40,
                                    ),
                                  );
                                },
                              ),
                            ),
                            Expanded(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  AnimatedOpacity(
                                    opacity: _isTextVisible ? 1.0 : 0.0,
                                    duration: Duration(milliseconds: 300),
                                    child: Text(
                                      targetLanguageText,
                                      style: TextStyle(
                                        fontSize: 20,
                                        color: Colors.white,
                                      ),
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
                          color: Color.fromRGBO(77, 91, 129, 0.45),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: Color.fromRGBO(40, 62, 117, 0.45),
                              width: 3.5
                          ),
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
                              margin: EdgeInsets.fromLTRB(10, 18, 10, 0),
                              padding: EdgeInsets.all(10),
                              child: AnimatedOpacity(
                                opacity: _isTextVisible ? 1.0 : 0.0,
                                duration: Duration(milliseconds: 300),
                                child: Text(
                                  sourceText.isEmpty
                                      ? 'Введите текст'
                                      : sourceText,
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontFamily: 'Times New Roman',
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                            ),
                            Positioned(
                              top: 10,
                              right: 10,
                              child: IconButton(
                                onPressed: isTranslating
                                    ? null
                                    : () {
                                  setState(() {
                                    _updateTextVisibility();
                                    Future.delayed(Duration(milliseconds: 500), () {
                                      setState(() {
                                        clearText();
                                      });
                                    });
                                  });
                                },
                                icon: Icon(
                                  Icons.close,
                                  color: isTranslating ? Colors.grey : Colors.white,
                                ),
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
                          color: Color.fromRGBO(37, 49, 73, 0.6),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: Color.fromRGBO(35, 47, 74, 0.6),
                              width: 3.5
                          ),
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
                              margin: EdgeInsets.fromLTRB(10, 18, 10, 0),
                              padding: EdgeInsets.all(10),
                              child: AnimatedOpacity(
                                opacity: _isTextVisible ? 1.0 : 0.0,
                                duration: Duration(milliseconds: 300),
                                child: Text(
                                  targetText.isEmpty
                                      ? "Перевод"
                                      : targetText,
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontFamily: 'Times New Roman',
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.left,
                                ),
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
                      Container(
                        margin: EdgeInsets.fromLTRB(10,18,10,0),
                        decoration: BoxDecoration(
                          color: Color.fromRGBO(16, 216, 49, 0.8),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              spreadRadius: 3,
                              blurRadius: 5,
                              offset: Offset(0, 3)
                          ),],
                        ),
                        child: TextButton(
                          onPressed: isTranslating
                              ? null
                              : () {
                            setState(() {
                              translateText();
                            });
                          },
                          child: Text(
                            'Перевести',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ),
                      BuildButtonRow(['ā', 'ē', 'ё̄', '̄ӣ', 'ӈ', 'о̄', 'ӯ', 'ы̄', 'э̄', 'ю̄', 'я̄']),
                      BuildButtonRow(['й', 'ц', 'у', 'к', 'е', 'н', 'г', 'ш', 'щ', 'з', 'х', 'ъ']),
                      BuildButtonRow(['ф', 'ы', 'в', 'а', 'п', 'р', 'о', 'л', 'д', 'ж', 'э']),
                      BuildButtonRow(['↑', 'я', 'ч', 'с', 'м', 'и', 'т', 'ь', 'б', 'ю', '',]),
                      BuildButtonRow(['Пробел']),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  Widget BuildButtonRow(List<String> buttons) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: buttons.map((button) {
        return ButtonStyle(button);
      }).toList(),
    );
  }

  Widget ButtonStyle(String label) {
    double valButWidth = 45;
    double valButHeight = 65;
    if (label == 'Пробел') {
      valButWidth = 140;
      valButHeight = 90;
    }
    return GestureDetector(
      onTap: () {
        //Сюда функцию для ввода строки
      },
      child: Container(
        margin: EdgeInsets.all(8),
        width: valButWidth,
        height: valButHeight,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Color.fromRGBO(60, 70, 101, 0.60),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: Color.fromRGBO(53, 63, 90, 0.85),
              width: 3.5
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 35,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
