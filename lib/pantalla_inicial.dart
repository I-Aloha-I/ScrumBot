import 'package:flutter/material.dart';
import 'lista_tareas_page.dart';
import 'scrum_bot_page.dart';
import 'crear_historia_page.dart'; // Asegúrate de tener este archivo

class PantallaInicial extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Menú Principal')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Botón para consultar al ScrumBot
            ElevatedButton(
              child: Text('Consultar a ScrumBot'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                textStyle: TextStyle(fontSize: 16),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ScrumBotPage()),
                );
              },
            ),
            SizedBox(height: 16),

            // Botón para ver la lista de tareas
            ElevatedButton(
              child: Text('Ver lista de tareas'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ListaTareasPage()),
                );
              },
            ),
            SizedBox(height: 16),

            // 🔥 Nuevo botón para crear historias de usuario
            ElevatedButton(
              child: Text('Crear historia de usuario'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CrearHistoriaPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
