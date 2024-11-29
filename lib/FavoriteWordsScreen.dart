import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

class FavoriteWordsScreen extends StatefulWidget {
  @override
  _FavoriteWordsScreenState createState() => _FavoriteWordsScreenState();
}

class _FavoriteWordsScreenState extends State<FavoriteWordsScreen> {
  late VideoPlayerController _controllerVideo;
  List<Map<String, String>> favoriteWords = [
    {'original': 'Привет', 'translated': 'Hello'},
    {'original': 'Ооооооооооочень длинное предложение', 'translated': 'A very long sentence that needs to be truncated'},
    {'original': 'Спасибо', 'translated': 'Thank you'},
  ];
  List<bool> isExpandedList = [];

  @override
  void initState() {
    super.initState();
    _controllerVideo = VideoPlayerController.asset("src/design/material/background2.mp4")
      ..initialize().then((_) {
        setState(() {
          _controllerVideo.setLooping(true);
          _controllerVideo.setVolume(0);
          _controllerVideo.play();
          isExpandedList = List.generate(favoriteWords.length, (_) => false);
        });
      });
  }

  @override
  void dispose() {
    _controllerVideo.dispose();
    super.dispose();
  }

  bool _isTextOverflowing(String text, double maxWidth, TextStyle style) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: maxWidth);
    return textPainter.didExceedMaxLines;
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
                centerTitle: true,
                title: Text(
                  'Избранное',
                  style: TextStyle(
                    fontSize: 24,
                    fontFamily: 'Montserrat',
                    color: Colors.white,
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: favoriteWords.asMap().entries.map((entry) {
                      int index = entry.key;
                      String originalWord = entry.value['original']!;
                      String translatedWord = entry.value['translated']!;

                      return LayoutBuilder(
                        builder: (context, constraints) {
                          bool isOriginalOverflowing = _isTextOverflowing(
                              originalWord, constraints.maxWidth, TextStyle(fontSize: 20, fontFamily: 'Montserrat'));
                          bool isTranslatedOverflowing = _isTextOverflowing(
                              translatedWord, constraints.maxWidth, TextStyle(fontSize: 20, fontFamily: 'Montserrat'));

                          return Container(
                            width: double.infinity,
                            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                            child: Card(
                              margin: EdgeInsets.zero,
                              color: Color.fromRGBO(9, 147, 140, 1),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      originalWord,
                                      maxLines: isExpandedList[index] ? null : 1,
                                      overflow: isExpandedList[index] ? TextOverflow.visible : TextOverflow.ellipsis,
                                      style: TextStyle(fontSize: 20, fontFamily: 'Montserrat', color: Colors.white),
                                      textAlign: TextAlign.center,
                                    ),
                                    Text(
                                      '—',
                                      style: TextStyle(fontSize: 20, fontFamily: 'Montserrat', color: Colors.white),
                                    ),
                                    Text(
                                      translatedWord,
                                      maxLines: isExpandedList[index] ? null : 1,
                                      overflow: isExpandedList[index] ? TextOverflow.visible : TextOverflow.ellipsis,
                                      style: TextStyle(fontSize: 20, fontFamily: 'Montserrat', color: Colors.white),
                                      textAlign: TextAlign.center,
                                    ),
                                    if (isOriginalOverflowing || isTranslatedOverflowing)
                                      IconButton(
                                        icon: Icon(
                                          isExpandedList[index] ? Icons.expand_less : Icons.expand_more,
                                        ),
                                        color: Colors.white,
                                        onPressed: () {
                                          setState(() {
                                            isExpandedList[index] = !isExpandedList[index];
                                          });
                                        },
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
