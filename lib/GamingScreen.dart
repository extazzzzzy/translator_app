import 'dart:math'; // Для генерации случайных чисел
import 'package:excel/excel.dart' as excel; // Для работы с Excel
import 'package:flutter/services.dart'; // Для загрузки ассетов
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:http/http.dart' as http;
import 'dart:ui';

class GameScreen extends StatefulWidget
{
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
{

  Future<void> pickRandomRow() async
  {
    try
    {
      // Загружаем файл из ассетов
      ByteData data = await rootBundle.load('src/translation_db/words.xlsx');
      var bytes = data.buffer.asUint8List();

      // Парсим Excel
      var excelFile  = excel.Excel.decodeBytes(bytes);

      // Читаем данные из первого листа
      for (var table in excelFile.tables.keys)
      {
        var sheet = excelFile.tables[table];
        if (sheet != null) {
          // Проверяем, что в таблице есть строки
          if (sheet.rows.isEmpty) {
            print("Таблица пуста!");
            return;
          }

          int randomIndex = Random().nextInt(sheet.rows.length - 1) + 1;
          var randomRow = sheet.rows[randomIndex];

          // Получаем значения из первого и третьего столбцов
          var firstColumnValue = randomRow[0]?.value ?? "пусто";
          var thirdColumnValue = randomRow[2]?.value ?? "пусто";

          // Выводим результат
          print("Случайная строка $randomIndex");
          print("Первый столбец: $firstColumnValue");
          print("Третий столбец: $thirdColumnValue");
        }
        break; // Читаем только первый лист
      }
    }
    catch (e)
    {
      print("Ошибка: $e");
    }
  }

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
  }

  @override
  void dispose() {
    _controllerVideo.dispose();
    _controllerAnimation.dispose();
    super.dispose();
  }
  String sourceText = '';

  void clearText() {
    sourceText = '';
  }

  void editSourceText(String label) {
    if (label == '⌫' && sourceText.length > 0) {
      sourceText = sourceText.substring(0, sourceText.length - 1);
    }
    else if (label == '') {
      sourceText += ' ';
    }
    else {
      if (isCapsLock == false) {
        sourceText += label;
      }
      else {
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
                        onPressed: (){},
                        icon: Icon(
                          Icons.class_rounded,
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
                        onPressed: (){},
                        icon: Icon(
                          Icons.ac_unit,
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
                                  'src/img/1.png',
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
                                              "Вопрос",
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
                                  ),
                                  Container(
                                    height: 130,
                                    width: 180,
                                    margin: EdgeInsets.only(top: 15, right: 10),
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
                                    child: Stack(
                                      children: [
                                        Container(
                                          margin: EdgeInsets.fromLTRB(10, 18, 10, 0),
                                          padding: EdgeInsets.all(10),
                                          child: AnimatedOpacity(
                                            opacity: _isTextVisible ? 1.0 : 0.0,
                                            duration: Duration(milliseconds: 300),
                                            child: Text(
                                              "Ответ",
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
                                  ),
                                ],
                              )
                            ],
                          ),
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
                        BuildButtonRow(['ā', 'ē', 'ё̄', 'ӣ', 'ӈ', 'о̄', 'ӯ', 'ы̄', 'э̄', 'ю̄', 'я̄']),
                        BuildButtonRow(['й', 'ц', 'у', 'к', 'е', 'н', 'г', 'ш', 'щ', 'з', 'х', 'ъ']),
                        BuildButtonRow(['ф', 'ы', 'в', 'а', 'п', 'р', 'о', 'л', 'д', 'ж', 'э']),
                        BuildButtonRow(['↑', 'я', 'ч', 'с', 'м', 'и', 'т', 'ь', 'б', 'ю', '⌫',]),
                        BuildButtonRow([',', 'Пробел', '.']),
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
                                '1/10',
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
  Widget BuildButtonRow(List<String> buttons) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: buttons.map((button) {
        return ButtonStyle(button);
      }).toList(),
    );
  }

  bool isCapsLock = false;

  Widget ButtonStyle(String label) {
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
        setState(() {});
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
          'Проверить',
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
