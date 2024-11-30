import 'dart:math';
import 'package:excel/excel.dart' as exel;
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:translator/HomeScreen.dart';
import 'package:translator/selectTest.dart';
import 'dart:async';
import 'package:video_player/video_player.dart';

class GamingScreen extends StatefulWidget
{
  const GamingScreen({super.key});

  @override
  State<GamingScreen> createState() => _GamingScreenState();
}

class _GamingScreenState extends State<GamingScreen>
{
  String defaultSheetName = "words";
  List<Map<String, String>> pairs = [];
  int rightAnswersCount = 0;
  int taskCount = 10;
  int currentTaskIndex = 0;
  int timer = 0;
  late Timer _timer;

  bool isAnswerShowing = false;
  String buttonText = "Проверить";

  String sourceLanguage = "Мансийский";
  String targetLanguage = "Русский";
  String question = "";
  String answer = "Привет! Давай поиграем!";

  List<String> goodGirlFaceNames = ["glad", "merry1", "merry2", "merry3"];
  List<String> badGirlFaceNames = ["angry", "sad", "confused", "surprised"];
  String girlFaceName = "glad";

  Future<void> pickRandomRows(int count) async
  {
    try
    {
      ByteData data = await rootBundle.load('src/translation_db/translations.xlsx');
      var bytes = data.buffer.asUint8List();

      var excel = exel.Excel.decodeBytes(bytes);

      var sheet = excel.tables[defaultSheetName];
      if (sheet == null)
      {
        throw Exception("Лист '$defaultSheetName' не найден!");
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
        question = pairs[currentTaskIndex][sourceLanguage]!;
        sourceText = pairs[currentTaskIndex][targetLanguage]!;
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
      if (!isAnswerShowing)
      {
        clearText();
        var correctAnswer = pairs[currentTaskIndex][targetLanguage];
        currentTaskIndex++;
        
        if (currentTaskIndex >= pairs.length)
        {
          if (buttonText == "Вернуться")
          {
            // ПЕРЕХОД НА ДРУГУЮ СТРАНИЦУ
          }
          else
          {
            _timer.cancel();
            isAnswerShowing = false;
            buttonText = "Вернуться";
            question = "Выполнено верно: $rightAnswersCount/10";
            answer = "Время: ${timer ~/ 60} мин ${timer % 60} сек";
            currentTaskIndex--;
          }
        }
        else
        {
          question = pairs[currentTaskIndex][sourceLanguage]!;
          answer = "Правильный ответ: " + pairs[currentTaskIndex-1][targetLanguage]!;
          sourceText = pairs[currentTaskIndex][targetLanguage]!; // ЧИТ НА ОТВЕТ
        }

        if (userAnswer.trim().toLowerCase() == correctAnswer?.trim().toLowerCase())
        {
          girlFaceName = goodGirlFaceNames[Random().nextInt(goodGirlFaceNames.length - 1)];
          rightAnswersCount++;
        }
        else
        {
          girlFaceName = badGirlFaceNames[Random().nextInt(badGirlFaceNames.length - 1)];
        }

        isAnswerShowing = true;
        buttonText = "Далее";
      }
      else
      {
        isAnswerShowing = false;
        buttonText = "Проверить";
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
                                margin: EdgeInsets.only(right: 15, left: 15, bottom: 20),
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
                                      borderRadius: BorderRadius.circular(10),
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
                                  Visibility(
                                    visible: isAnswerShowing,
                                    child: Container(
                                      height: 130,
                                      width: 180,
                                      margin: EdgeInsets.only(top: 15, right: 10),
                                      decoration: BoxDecoration(
                                        color: Color.fromRGBO(9, 147, 140, 0.45),
                                        borderRadius: BorderRadius.circular(10),
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
                                            child: AnimatedOpacity(
                                              opacity: _isTextVisible ? 1.0 : 0.0,
                                              duration: Duration(milliseconds: 300),
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
                                (currentTaskIndex+1).toString() + '/10',
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
          color: Color.fromRGBO(7, 96, 90, 0.45),
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
