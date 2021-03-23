import 'package:flutter/material.dart';
import 'package:reza_uts/screens/list_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Reza UTS',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ListScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
