import 'package:flutter/material.dart';
import 'ver_historias_page.dart';
import 'crear_historia_page.dart';
import 'crear_tarea_page.dart';
import 'lista_tareas_page.dart';
import 'scrum_bot_page.dart';

class PantallaInicial extends StatelessWidget {
  const PantallaInicial({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'ScrumBot',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        elevation: 4,
        leading: const Icon(Icons.menu),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView(
          children: [
            const SizedBox(height: 20),
            _buildCard(
              context,
              icon: Icons.library_books,
              title: 'Ver Historias',
              subtitle: 'Revisa las historias creadas',
              page: VerHistoriasPage(),
            ),
            _buildCard(
              context,
              icon: Icons.add_circle_outline,
              title: 'Crear Historia',
              subtitle: 'Agrega una nueva historia de usuario',
              page: CrearHistoriaPage(),
            ),
            _buildCard(
              context,
              icon: Icons.add_task,
              title: 'Crear Tarea',
              subtitle: 'Agrega una nueva tarea al Sprint',
              page: CrearTareaPage(),
            ),
            _buildCard(
              context,
              icon: Icons.task_alt,
              title: 'Lista de Tareas',
              subtitle: 'Tareas del Sprint',
              page: ListaTareasPage(),
            ),
            _buildCard(
              context,
              icon: Icons.smart_toy,
              title: 'Scrum Bot',
              subtitle: 'Habla con el asistente',
              page: ScrumBotPage(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context,
      {required IconData icon, required String title, required String subtitle, required Widget page}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Icon(icon, size: 40, color: Colors.indigo),
        title: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => page),
        ),
      ),
    );
  }
}