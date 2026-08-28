import 'package:flutter/material.dart';
import 'utils/constants.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Mi Tienda Virtual',

      home: Scaffold(body: Center(child: Text('Hello World!'))),
    );
  }
}
