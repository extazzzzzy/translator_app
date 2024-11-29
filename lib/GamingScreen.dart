import 'dart:math'; // Для генерации случайных чисел
import 'package:excel/excel.dart'; // Для работы с Excel
import 'package:flutter/services.dart'; // Для загрузки ассетов
import 'package:flutter/material.dart';

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
      var excel = Excel.decodeBytes(bytes);

      // Читаем данные из первого листа
      for (var table in excel.tables.keys)
      {
        var sheet = excel.tables[table];
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

  @override
  void initState()
  {
    super.initState();

    // Запускаем выбор случайной строки при инициализации
    //pickRandomRow();
    pickRandomRow();
  }

  @override
  Widget build(BuildContext context)
  {
    return Scaffold();
  }
}
