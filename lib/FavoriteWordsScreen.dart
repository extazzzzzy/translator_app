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
    {'original': 'Длинное предложение', 'translated': 'A very long sentence that needs to be truncated'},
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
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
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
                      return Container(
                        width: double.infinity,
                        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        child: Card(
                          margin: EdgeInsets.zero,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  '$originalWord — $translatedWord',
                                  maxLines: isExpandedList[index] ? null : 1,
                                  overflow: isExpandedList[index] ? TextOverflow.visible : TextOverflow.ellipsis,
                                  style: TextStyle(fontSize: 18),
                                ),
                                IconButton(
                                  icon: Icon(
                                    isExpandedList[index] ? Icons.expand_less : Icons.expand_more,
                                  ),
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
