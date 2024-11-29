import 'package:flutter/material.dart';
import 'main.dart';

class selectTestScreen extends StatefulWidget {
  @override
  selectTest createState() => selectTest();
}

class selectTest extends State<selectTestScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          alignment: Alignment.center,
          padding: EdgeInsets.only(top: 20, right:  25),
          child: Text(
            'Select test',
            style: TextStyle(
              fontSize: 27,
              fontFamily: 'Times New Roman',
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            overflow: TextOverflow.visible,
          ),
        ),
      ),
        body: Column(
          children: [
            Container(
              alignment: Alignment.center,
              margin: EdgeInsets.only(top: 20, left: 10, right: 10, bottom: 15),
              padding: EdgeInsets.only(top: 20, left: 10, right: 10, bottom: 15),
              decoration: BoxDecoration(
                color: Color.fromRGBO(151, 151, 151, 1.0),
                borderRadius: BorderRadius.circular(12),
              ),
              child: GestureDetector(
                onTap: () {
                  /*Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => gameScreen(),
                    ));*/
                },
                child: Text(
                  'Слова',
                  style: TextStyle(
                    fontSize: 25,
                  ),
                ),
              ),
            ),
            Container(
              alignment: Alignment.center,
              margin: EdgeInsets.only(top: 20, left: 10, right: 10, bottom: 15),
              padding: EdgeInsets.only(top: 20, left: 10, right: 10, bottom: 15),
              decoration: BoxDecoration(
                color: Color.fromRGBO(151, 151, 151, 1.0),
                borderRadius: BorderRadius.circular(12),
              ),
              child: GestureDetector(
                onTap: () {
                  /*Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => gameScreen(),
                    ));*/
                },
                child: Text(
                  'Фразы',
                  style: TextStyle(
                    fontSize: 25,
                  ),
                ),
              ),
            ),
            Container(
              alignment: Alignment.center,
              margin: EdgeInsets.only(top: 20, left: 10, right: 10, bottom: 15),
              padding: EdgeInsets.only(top: 20, left: 10, right: 10, bottom: 15),
              decoration: BoxDecoration(
                color: Color.fromRGBO(151, 151, 151, 1.0),
                borderRadius: BorderRadius.circular(12),
              ),
              child: GestureDetector(
                onTap: () {
                  /*Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => gameScreen(),
                    ));*/
                },
                child: Text(
                  'Предложения',
                  style: TextStyle(
                    fontSize: 25,
                  ),
                ),
              ),
            ),
          ],
        )
    );
  }
}