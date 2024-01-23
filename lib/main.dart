import 'package:flutter/material.dart';
import 'package:tremor_detection/menu.dart';
import 'package:tremor_detection/review.dart';
import 'package:tremor_detection/trends.dart';

void main() {
  runApp(const MaterialApp(
    title: 'Home',
    home: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.background,
        title: const Text("Tremor detection App"),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            ElevatedButton(
              child: const Text('Neue Aufgabe'),
              onPressed: () {
                Navigator.push(
                  context, 
                  MaterialPageRoute(builder: (context) => const Menu()),
                );
            },
            ),
            ElevatedButton(
              child: const Text('Ergebnisse anschauen'),
              onPressed: () {
                Navigator.push(
                  context, 
                  MaterialPageRoute(builder: (context) => const Review()),
                );
            },
            ),
            ElevatedButton(
              child: const Text('Trends anschauen'),
              onPressed: () {
                Navigator.push(
                  context, 
                  MaterialPageRoute(builder: (context) => const Trends()),
                );
            },
            ),
          ],
      ),
      ),
    );
  }
}


