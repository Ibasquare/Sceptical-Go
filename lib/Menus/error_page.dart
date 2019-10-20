import 'package:flutter/material.dart';
import '../main.dart';

Widget errorPage(BuildContext context, String message)
{
  return Scaffold(
      appBar: AppBar(
        title: Text("Sceptical Go", style: new TextStyle(fontFamily: 'AA')),
      ),
      floatingActionButton: new FloatingActionButton(
        child: new Icon(Icons.arrow_back),
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            MovingPlanet(),
            Text(
              message,
              textAlign: TextAlign.center,
              style: new TextStyle(fontSize: 20.0, color: Colors.black, fontFamily: 'AA'),
            )
          ],
        ),
      )
  );
}