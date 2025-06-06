import 'package:flutter/material.dart';
import 'chat_page.dart';
import 'lista_tareas_page.dart';

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
              child: Text('Abrir Chat'),
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
          ],
        ),
      ),
    );
  }
}
