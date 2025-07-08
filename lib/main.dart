import 'package:flutter/material.dart';
import 'pantalla_inicial.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestor de Tareas',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: PantallaInicial(),
    );
  }
}