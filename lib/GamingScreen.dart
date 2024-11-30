import 'dart:math';
import 'package:excel/excel.dart' as exel;
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:translator/HomeScreen.dart';
import 'package:translator/selectTest.dart';
import 'dart:async';
import 'package:video_player/video_player.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GamingScreen extends StatefulWidget
{
  const GamingScreen({super.key, required this.difficulty, required  this.sourceLanguage, required  this.targetLanguage});
  
  final String difficulty;
  final String sourceLanguage;
  final String targetLanguage;

  @override
  State<GamingScreen> createState() => _GamingScreenState();
}

class _GamingScreenState extends State<GamingScreen>  with SingleTickerProviderStateMixin 
{
  List<Map<String, String>> pairs = [];
  int rightAnswersCount = 0;
  int taskCount = 10;
  int currentTaskIndex = 0;
  int timer = 0;
  late Timer _timer;

  bool isAnswerShowing = false;
  int isAnswerTrue = 0; //для смены цвета по ответу
  String buttonText = "Проверить";

  String question = "";
  String answer = "Привет! Давай поиграем!";

  List<String> goodGirlFaceNames = ["glad", "merry1", "surprised"];
  List<String> badGirlFaceNames = ["angry", "sad", "confused"];
  String girlFaceName = "glad";
  String newGirlFaceName = "";

  void saveGameData(int rightAnswersCount, int time) async
  {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('rightAnswersCount', rightAnswersCount);
    prefs.setInt('time', time);
  }

  Future<void> pickRandomRows(int count) async
  {
    try
    {
      ByteData data = await rootBundle.load('src/translation_db/translations.xlsx');
      var bytes = data.buffer.asUint8List();

      var excel = exel.Excel.decodeBytes(bytes);

      var sheet = excel.tables[widget.difficulty];
      if (sheet == null)
      {
        throw Exception("Лист '${widget.difficulty}' не найден!");
      }

      List<int> indexes = [];
      while (indexes.length < count)
      {
        int randomIndex = Random().nextInt(sheet.rows.length - 1) + 1;
        if (!indexes.contains(randomIndex))
        {
          indexes.add(randomIndex);
        }
      }

      List<Map<String, String>> tempPairs = [];
      for (int index in indexes)
      {
        var row = sheet.rows[index];
        var firstColumnValue = row[0]?.value?.toString().toLowerCase() ?? "пусто";
        var thirdColumnValue = row[2]?.value?.toString().toLowerCase() ?? "пусто";
        tempPairs.add
          ({
          "Русский": firstColumnValue,
          "Мансийский": thirdColumnValue,
        });
      }

      setState(()
      {
        pairs = tempPairs;
        rightAnswersCount = 0;
        currentTaskIndex = 0;
        timer = 0;
        question = pairs[currentTaskIndex][widget.sourceLanguage]!;
        sourceText = pairs[currentTaskIndex][widget.targetLanguage]!;
        isAnswerTrue = 0;
      });

      _timer = Timer.periodic(Duration(seconds: 1), (timer)
      {
        setState(()
        {
          this.timer++;
        });
      });

    }
    catch(e)
    {
      print("Ошибка: $e");
    }
  }

  void checkAnswer(String userAnswer)
  {
    setState(()
    {
      if (buttonText == "Вернуться")
      {
        saveGameData(rightAnswersCount, timer);
        Navigator.pushReplacement
        (
          context,
          MaterialPageRoute(builder: (context) => selectTestScreen()),
        );
      }

      if (buttonText == "Проверить")
      {
        var correctAnswer = pairs[currentTaskIndex][widget.targetLanguage];

        if (userAnswer.trim().toLowerCase() == correctAnswer?.trim().toLowerCase())
        {
          do
          {
            newGirlFaceName = goodGirlFaceNames[Random().nextInt(goodGirlFaceNames.length)];
          }
          while (newGirlFaceName == girlFaceName);
          girlFaceName = newGirlFaceName;

          girlFaceName = newGirlFaceName;
          rightAnswersCount++;
          isAnswerTrue = 1;
        }
        else
        {
          do
          {
            newGirlFaceName = badGirlFaceNames[Random().nextInt(badGirlFaceNames.length)];
          }
          while (newGirlFaceName == girlFaceName);
          girlFaceName = newGirlFaceName;
          isAnswerTrue = 2;
          isAnswerShowing = true;
          answer = "Правильный ответ: " + pairs[currentTaskIndex][widget.targetLanguage]!;
        }
      }
      
      if (currentTaskIndex >= pairs.length-1 && buttonText == "Далее")
        {
          _timer.cancel();
          isAnswerShowing = true;
          buttonText = "Вернуться";
          question = "Выполнено верно: $rightAnswersCount/10";
          answer = "Время: ${timer ~/ 60} мин ${timer % 60} сек";

          if (rightAnswersCount > 5)
          {
            do
            {
              newGirlFaceName = goodGirlFaceNames[Random().nextInt(goodGirlFaceNames.length)];
            }
            while (newGirlFaceName == girlFaceName);
            girlFaceName = newGirlFaceName;
          }
          else
          {
            do
            {
              newGirlFaceName = badGirlFaceNames[Random().nextInt(badGirlFaceNames.length)];
            }
            while (newGirlFaceName == girlFaceName);
            girlFaceName = newGirlFaceName;
          }
        }
        else
        {
          if (buttonText == "Далее")
          {
            currentTaskIndex++;
            clearText();
            sourceText = pairs[currentTaskIndex][widget.targetLanguage]!; // ЧИТ НА ОТВЕТ
            question = pairs[currentTaskIndex][widget.sourceLanguage]!;
            isAnswerShowing = false;
            buttonText = "Проверить";
            isAnswerTrue = 0;
          }
          else
          {
            buttonText = "Далее";
          }
        }
    });
  }

  late VideoPlayerController _controllerVideo;
  late AnimationController _controllerAnimation;
  late Animation<double> _rotationAnimation;
  bool _isTextVisible = true;

  bool isTranslating = false;

  @override
  void initState()
  {
    super.initState();
    _controllerAnimation = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    );

    _controllerVideo = VideoPlayerController.asset("src/design/material/background2.mp4")
      ..initialize().then((_) {
        setState(() {
          _controllerVideo.setLooping(true);
          _controllerVideo.setVolume(0);
          _controllerVideo.play();
        });
      });
    pickRandomRows(taskCount);
  }

  @override
  void dispose()
  {
    _controllerVideo.dispose();
    _controllerAnimation.dispose();
    _timer.cancel();
    super.dispose();
  }
  String sourceText = '';

  void clearText()
  {
    sourceText = '';
  }

  void editSourceText(String label)
  {
    if (label == '⌫' && sourceText.length > 0)
    {
      sourceText = sourceText.substring(0, sourceText.length - 1);
    }
    else if (label == '')
    {
      sourceText += ' ';
    }
    else {
      if (isCapsLock == false)
      {
        sourceText += label;
      }
      else
      {
        sourceText += label.toUpperCase();
      }
    }
  }

  @override
  Widget build(BuildContext context)
  {
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
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          onPressed: (){
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => selectTestScreen()),
                            );
                          },
                          icon: Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Мансийский переводчик',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontFamily: 'Montserrat',
                          ),
                        ),
                        IconButton(
                          onPressed: (){
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => HomeScreen()),
                            );
                          },
                          icon: Icon(
                            Icons.home,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                              child: Row(
                                  children: [
                                    Container(
                                      margin: EdgeInsets.only(right: 15, left: 15, top: 110),
                                      child: Image.asset(
                                        "src/img/" + girlFaceName + ".png",
                                        height: 180,
                                      ),
                                    ),
                                    Column(
                                      children: [
                                        Container(
                                          height: 130,
                                          width: 180,
                                          margin: EdgeInsets.only(top: 15, right: 10),
                                          decoration: BoxDecoration(
                                            color: Color.fromRGBO(9, 147, 140, 0.45),
                                            borderRadius: BorderRadius.only(
                                              topRight: Radius.circular(40),
                                              topLeft: Radius.circular(65),
                                              bottomLeft: Radius.circular(0),
                                              bottomRight: Radius.circular(65),
                                            ),
                                            border: Border.all(
                                              color: Color.fromRGBO(6, 78, 73, 0.3),
                                              width: 3.5,
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
                                                child: AnimatedOpacity
                                                  (
                                                  opacity: _isTextVisible ? 1.0 : 0.0,
                                                  duration: Duration(milliseconds: 300),
                                                  child: Text(
                                                    question,
                                                    style: TextStyle(
                                                      fontSize: 20,
                                                      fontFamily: 'Montserrat',
                                                      fontWeight: FontWeight.bold,
                                                      color: Colors.white,
                                                    ),
                                                    textAlign: TextAlign.left,),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        AnimatedOpacity(
                                            opacity: isAnswerShowing ? 1.0 : 0.0,
                                            duration: Duration(milliseconds: 300),
                                            child: Container(
                                              height: 130,
                                              width: 180,
                                              margin: EdgeInsets.only(top: 15, right: 10),
                                              decoration: BoxDecoration(
                                                color: Color.fromRGBO(9, 147, 140, 0.45),
                                                borderRadius: BorderRadius.only(
                                                  topRight: Radius.circular(65),
                                                  topLeft: Radius.circular(0),
                                                  bottomLeft: Radius.circular(65),
                                                  bottomRight: Radius.circular(40),
                                                ),
                                                border: Border.all(
                                                  color: Color.fromRGBO(6, 78, 73, 0.3),
                                                  width: 3.5,
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
                                                    child: Text(
                                                      answer,
                                                      style: TextStyle(
                                                        fontSize: 20,
                                                        fontFamily: 'Montserrat',
                                                        fontWeight: FontWeight.bold,
                                                        color: Colors.white,
                                                      ),
                                                      textAlign: TextAlign.left,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            )
                                        ),
                                      ],
                                    )
                                  ]
                              )
                          ),
                          Container(
                            height: 100,
                            width: 390,
                            margin: EdgeInsets.only(top: 15, right: 10, left: 10),
                            decoration: BoxDecoration(
                              color: Color.fromRGBO(4, 61, 58, 0.6),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: (() {
                                    switch (isAnswerTrue) {
                                      case 1:
                                        return Color.fromRGBO(0, 183, 0, 1.0);
                                      case 2:
                                        return Color.fromRGBO(255, 0, 0, 1.0);
                                      default:
                                        return Color.fromRGBO(6, 78, 73, 0.3);
                                    }
                                  })(),
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
                                      sourceText.isEmpty ? 'Введите ответ' : sourceText,
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontFamily: 'Montserrat',
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
                                        clearText();
                                      });
                                    },
                                    icon: Icon(
                                      Icons.close,
                                      color: isTranslating ? Colors.grey : Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(margin: EdgeInsets.symmetric(vertical: 2),),
                          buildButtonRow(['ā', 'ē', 'ё̄', 'ӣ', 'ӈ', 'о̄', 'ӯ', 'ы̄', 'э̄', 'ю̄', 'я̄']),
                          buildButtonRow(['й', 'ц', 'у', 'к', 'е', 'н', 'г', 'ш', 'щ', 'з', 'х', 'ъ']),
                          buildButtonRow(['ф', 'ы', 'в', 'а', 'п', 'р', 'о', 'л', 'д', 'ж', 'э']),
                          buildButtonRow(['↑', 'я', 'ч', 'с', 'м', 'и', 'т', 'ь', 'б', 'ю', '⌫',]),
                          buildButtonRow([',', 'Пробел', '.']),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Container(width: 70,),
                              BuildCheckTheAnswer(),
                              Container(
                                padding: EdgeInsets.symmetric(vertical: 3, horizontal: 5),
                                decoration: BoxDecoration(
                                  color: Color.fromRGBO(9, 147, 140, 0.45),
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
                                  (currentTaskIndex < 10 ? (currentTaskIndex+1) : currentTaskIndex) .toString() + '/10',
                                  style: TextStyle(
                                    fontSize: 25,
                                    fontFamily: 'Montserrat',
                                    color: Colors.white,
                                  ),
                                ),
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ]
        )
    );
  }
  Widget buildButtonRow(List<String> buttons) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: buttons.map((button) {
        return buttonStyle(button);
      }).toList(),
    );
  }

  bool isCapsLock = false;

  Widget buttonStyle(String label) {
    double valButWidth = 29;
    double valButHeight = 42;
    double borderCircul = 10;
    double margVert = 3;
    double margHoris = 3;
    if (label == 'Пробел') {
      valButWidth = 120;
      valButHeight = 35;
      label = '';
      borderCircul = 30;
      margVert = 8;
    }
    if (['ā','ē','ё̄','ӣ','ӈ','о̄','ӯ','ы̄','э̄','ю̄','я̄'].contains(label)) {
      margHoris = 3;
      margVert = 7;
    }
    else if (['й','ц','у','к','е','н','г','ш','щ','з','х','ъ'].contains(label)) {
      margHoris = 2;
      margVert = 3;
    }
    else if (['ф','ы','в','а','п','р','о','л','д','ж','э'].contains(label)) {
      margHoris = 3;
      margVert = 3;
    }
    else if (['↑','я','ч','с','м','и','т','ь','б','ю','⌫',].contains(label)) {
      margHoris = 2;
      margVert = 3;
    }
    return GestureDetector(
      onTap: () {
        setState(() {
          if (label == '↑') {
            isCapsLock = !isCapsLock;
          } else {
            editSourceText(label);
          }
        });
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: margHoris, vertical: margVert),
        width: valButWidth,
        height: valButHeight,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Color.fromRGBO(7, 96, 90, 0.8),
          borderRadius: BorderRadius.circular(borderCircul),
          border: Border.all(
              color: Color.fromRGBO(7, 96, 90, 0.45),
              width: 3.5
          ),
        ),
        child: Text(
          isCapsLock ? label.toUpperCase() : label,
          style: TextStyle(
            fontSize: 20,
            fontFamily: 'Montserrat',
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget BuildCheckTheAnswer() {
    return GestureDetector(
      onTap: () {
        checkAnswer(sourceText);
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 2),
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
          buttonText,
          style: TextStyle(
              fontSize: 25,
              color: Colors.white,
              fontFamily: 'Montserrat'
          ),
        ),
      ),
    );
  }
}