import 'package:flutter/material.dart';
import 'chat_page.dart';
import 'lista_tareas_page.dart';
import 'scrum_bot_page.dart'; // Importa la nueva pantalla

class PantallaInicial extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Menú Principal')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              child: Text('Abrir Chat de Tareas'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ChatPage()),
                );
              },
            ),
            SizedBox(height: 16),
            ElevatedButton(
              child: Text('Abrir lista de tareas'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ListaTareasPage()),
                );
              },
            ),
            SizedBox(height: 16), // Espacio adicional
            // Botón para el nuevo ScrumBot
            ElevatedButton(
              child: Text('Consultar a ScrumBot'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green, // Un color diferente para destacarlo
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ScrumBotPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}