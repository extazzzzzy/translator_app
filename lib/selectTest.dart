import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:translator/FavoriteWordsScreen.dart';
import 'package:translator/HomeScreen.dart';
import 'package:video_player/video_player.dart';
import 'package:translator/GamingScreen.dart';

class selectTestScreen extends StatefulWidget {
  @override
  selectTest createState() => selectTest();
}

class selectTest extends State<selectTestScreen>  with SingleTickerProviderStateMixin {
  late VideoPlayerController _controllerVideo;
  late AnimationController _controllerAnimation;
  late Animation<double> _rotationAnimation;
  bool _isTextVisible = true;
  bool isTranslating = false;

  String sourceLanguageText = 'Русский';
  String targetLanguageText = 'Мансийский';

  @override
  void initState() {
    super.initState();
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

    _controllerVideo = VideoPlayerController.asset("src/design/material/background2.mp4")
      ..initialize().then((_) {
        setState(() {
          _controllerVideo.setLooping(true);
          _controllerVideo.setVolume(0);
          _controllerVideo.play();
        });
      });
  }

  @override
  void dispose() {
    _controllerVideo.dispose();
    _controllerAnimation.dispose();
    super.dispose();
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

  void changeLanguage() {
    if (sourceLanguageText == 'Русский') {
      sourceLanguageText = 'Мансийский';
      targetLanguageText = 'Русский';
    }
    else {
      sourceLanguageText = 'Русский';
      targetLanguageText = 'Мансийский';
    }
  }

  double _fontSize = 0;
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 425) {
      _fontSize = 18;
    }
    else {
      _fontSize = 20;
    }
    return Scaffold(
        body: Stack(
          children: [
            Positioned.fill(
              child: _controllerVideo.value.isInitialized
                  ? VideoPlayer(_controllerVideo)
                  : Stack(
                children: [
                  Positioned.fill(
                    child: Image.asset(
                      'src/design/material/background_load.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                  Center(
                    child: CircularProgressIndicator(color: Colors.white,),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  centerTitle: true,
                  leading: IconButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => HomeScreen()),
                      );
                    },
                    icon: Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                    ),
                  ),
                  title: Text(
                    'Выбор \n задания',
                    style: TextStyle(
                      fontSize: 22,
                      fontFamily: 'Montserrat',
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                Container(
                  margin: EdgeInsets.only(top: 20, left: 10, right: 10),
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
                                  fontSize: _fontSize,
                                  color: Colors.white,
                                  fontFamily: 'Montserrat',
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
                                  fontSize: _fontSize,
                                  color: Colors.white,
                                  fontFamily: 'Montserrat',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          BuildGamingMod('Перевод слова', "words"),
                          BuildGamingMod('Перевод фразы', "phrases"),
                          BuildGamingMod('Перевод предложения', "sentences"),
                        ],
                      ),
                    )
                ),
              ],
            )
          ],
        )
    );
  }
  Widget BuildGamingMod(String label, String difficulty) {
    return Container(
      alignment: Alignment.center,
      margin: EdgeInsets.only(top: 20, left: 10, right: 10, bottom: 10),
      padding: EdgeInsets.only(top: 20, left: 10, right: 10, bottom: 15),
      decoration: BoxDecoration(
        color: Color.fromRGBO(9, 147, 140, 0.5),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
            color: Color.fromRGBO(8, 133, 126, 0.5),
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(
                fontSize: 25,
                color: Colors.white,
                fontFamily: 'Montserrat'
            ),
          ),
          Container(
            margin: EdgeInsets.only(top:15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Icon(
                  Icons.access_time,
                  color: Colors.white,
                ),
                Text(
                  '00:00', //заменить на лучшее время
                  style: TextStyle(
                      fontSize: 25,
                      color: Colors.white,
                      fontFamily: 'Montserrat'
                  ),
                ),
                Icon(
                  Icons.beenhere_outlined,
                  color: Colors.white,
                ),
                Text(
                  '7/10', //заменить на лучший результат
                  style: TextStyle(
                      fontSize: 25,
                      color: Colors.white,
                      fontFamily: 'Montserrat'
                  ),
                ),
              ],
            ),
          ),
          Container(
            child: GestureDetector(
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => GamingScreen(difficulty: difficulty, sourceLanguage: sourceLanguageText, targetLanguage: targetLanguageText,)),
                );
              },
              child: Container(
                margin: EdgeInsets.only(top:20),
                padding: EdgeInsets.symmetric(vertical: 3, horizontal: 5),
                decoration: BoxDecoration(
                  color: Color.fromRGBO(9, 147, 20, 0.45),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: Color.fromRGBO(6, 78, 73, 0.3),
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
                child: Text(
                  'Начать тест',
                  style: TextStyle(
                      fontSize: _fontSize,
                      color: Colors.white,
                      fontFamily: 'Montserrat'
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}