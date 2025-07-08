import 'package:flutter/material.dart';
import 'crear_historia_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestor de Scrum',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const MenuPrincipal(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MenuPrincipal extends StatelessWidget {
  const MenuPrincipal({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Menú Principal')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              child: const Text('Abrir Chat'),
              onPressed: () {
                // Navega a tu pantalla de chat si ya la tienes implementada
                // Navigator.push(context, MaterialPageRoute(builder: (_) => ChatPage()));
              },
            ),
            ElevatedButton(
              child: const Text('Lista de tareas'),
              onPressed: () {
                // Navega a tu pantalla de tareas si ya la tienes implementada
              },
            ),
            ElevatedButton(
              child: const Text('Crear Historia de Usuario'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CrearHistoriaPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
