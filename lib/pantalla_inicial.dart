import 'package:flutter/material.dart';
import 'lista_tareas_page.dart';
import 'scrum_bot_page.dart';

class PantallaInicial extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Menú Principal')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // El botón para el ScrumBot ahora es el principal para interacciones
            ElevatedButton(
              child: Text('Consultar a ScrumBot'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                textStyle: TextStyle(fontSize: 16)
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ScrumBotPage()),
                );
              },
            ),
            SizedBox(height: 16),
            // El botón para ver la lista de tareas sigue siendo útil
            ElevatedButton(
              child: Text('Ver lista de tareas'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ListaTareasPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}