import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:translator/HomeScreen.dart';
import 'package:video_player/video_player.dart';

class FavoriteWordsScreen extends StatefulWidget {
  @override
  _FavoriteWordsScreenState createState() => _FavoriteWordsScreenState();
}

class _FavoriteWordsScreenState extends State<FavoriteWordsScreen>
{
  late VideoPlayerController _controllerVideo;
  bool _isVideoInitialized = false;
  List<bool> isExpandedList = [];
  List<String> favoriteWords = [];
  void loadFavoriteWords() async
  {
    final prefs = await SharedPreferences.getInstance();
    favoriteWords = prefs.getStringList('favoriteWords') ?? [];
  }

  @override
  void initState() {
    super.initState();
    loadFavoriteWords();
    _controllerVideo = VideoPlayerController.asset("src/design/material/background2.mp4")
      ..initialize().then((_) {
        setState(() {
          _controllerVideo.setLooping(true);
          _controllerVideo.setVolume(0);
          _controllerVideo.play();
          isExpandedList = List.generate(favoriteWords.length ~/ 2, (_) => false);
        });
      });
    _isVideoInitialized = true;
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
                iconTheme: IconThemeData(color: Colors.white),
                centerTitle: true,
                leading: IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => HomeScreen()),
                    );
                  },
                ),
                title: Text(
                  'Избранное',
                  style: TextStyle(
                    fontSize: 24,
                    fontFamily: 'Montserrat',
                    color: Colors.white,
                  ),
                ),
                actions: [
                  IconButton(
                    icon: Icon(Icons.delete_forever, color: Colors.white),
                    onPressed: () async {
                      bool? confirmDelete = await showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('Удалить все?'),
                          content: Text('Вы уверены, что хотите удалить все избранные слова?'),
                          actions: [
                            TextButton(
                              child: Text(
                                'Отмена',
                                style: TextStyle(color: Colors.black),),
                              onPressed: () => Navigator.pop(context, false),
                            ),
                            TextButton(
                              child: Text(
                                  'Удалить',
                                style: TextStyle(color: Colors.black),
                              ),
                              onPressed: () => Navigator.pop(context, true),
                            ),
                          ],
                        ),
                      );

                      if (confirmDelete == true) {
                        setState(() {
                          favoriteWords.clear();
                          isExpandedList.clear();
                        });

                        final prefs = await SharedPreferences.getInstance();
                        await prefs.remove('favoriteWords');
                      }
                    },
                  ),
                ],
              ),


              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: List.generate(favoriteWords.length ~/ 2, (index) {
                      String originalWord = favoriteWords[index * 2];
                      String translatedWord = favoriteWords[index * 2 + 1];

                      return Dismissible(
                        key: Key('$index-${favoriteWords[index * 2]}'),
                        direction: DismissDirection.endToStart,
                        onDismissed: (direction) async {
                          setState(() {
                            favoriteWords.removeAt(index * 2);
                            favoriteWords.removeAt(index * 2);
                            isExpandedList.removeAt(index);
                          });

                          final prefs = await SharedPreferences.getInstance();
                          await prefs.setStringList('favoriteWords', favoriteWords);

                        },
                        background: Container(
                          alignment: Alignment.centerRight,
                          color: Colors.red,
                          padding: EdgeInsets.only(right: 20),
                          child: Icon(
                            Icons.delete,
                            color: Colors.white,
                          ),
                        ),
                        child: LayoutBuilder(
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
                        ),
                      );
                    }),
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