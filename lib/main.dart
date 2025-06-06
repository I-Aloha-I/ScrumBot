import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestor de Tareas',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: PantallaPrincipal(),
    );
  }
}

class Tarea {
  String titulo;
  String prioridad;
  int estimacion;
  DateTime fechaRegistro;

  Tarea({
    required this.titulo,
    required this.prioridad,
    required this.estimacion,
    required this.fechaRegistro,
  });
}

class PantallaPrincipal extends StatelessWidget {
  PantallaPrincipal({super.key});

  final List<Tarea> tareas = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Menú principal')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatPage(tareas: tareas),
                  ),
                );
              },
              child: const Text('Abrir Chat'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ListaTareasPage(tareas: tareas),
                  ),
                );
              },
              child: const Text('Abrir lista de tareas'),
            ),
          ],
        ),
      ),
    );
  }
}

class ChatPage extends StatefulWidget {
  final List<Tarea> tareas;
  const ChatPage({super.key, required this.tareas});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController controladorTexto = TextEditingController();
  String tituloTarea = '';
  String? prioridadSeleccionada;
  final List<String> mensajes = [];

  void enviarMensaje(String texto) {
    setState(() {
      mensajes.add("Tú: $texto");
    });

    if (texto.toLowerCase().startsWith("agregar tarea:")) {
      tituloTarea = texto.substring("agregar tarea:".length).trim();
      setState(() {
        mensajes.add("Bot: ¿Cuál es la prioridad de esta tarea (Alta, Media, Baja)?");
      });
    } else if (['alta', 'media', 'baja'].contains(texto.toLowerCase())) {
      prioridadSeleccionada = texto[0].toUpperCase() + texto.substring(1).toLowerCase();
      setState(() {
        mensajes.add("Bot: ¿Cuántas horas estimas que tomará esta tarea?");
      });
    } else if (int.tryParse(texto) != null && prioridadSeleccionada != null && tituloTarea.isNotEmpty) {
      final nuevaTarea = Tarea(
        titulo: tituloTarea,
        prioridad: prioridadSeleccionada!,
        estimacion: int.parse(texto),
        fechaRegistro: DateTime.now(),
      );
      widget.tareas.add(nuevaTarea);

      setState(() {
        mensajes.add("Bot: Tarea registrada: $tituloTarea, prioridad $prioridadSeleccionada, $texto horas.");
        tituloTarea = '';
        prioridadSeleccionada = null;
      });
    } else {
      setState(() {
        mensajes.add("Bot: No entendí eso. Si deseas registrar una tarea, escribe 'Agregar tarea: ...'");
      });
    }

    controladorTexto.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: mensajes.length,
              itemBuilder: (context, index) => ListTile(
                title: Text(mensajes[index]),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controladorTexto,
                    onSubmitted: enviarMensaje,
                    decoration: const InputDecoration(
                      labelText: 'Escribe tu mensaje...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => enviarMensaje(controladorTexto.text),
                  child: const Text('Enviar'),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class ListaTareasPage extends StatelessWidget {
  final List<Tarea> tareas;
  const ListaTareasPage({super.key, required this.tareas});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Tareas'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: tareas.isEmpty
          ? const Center(child: Text('No hay tareas registradas.'))
          : ListView.builder(
              itemCount: tareas.length,
              itemBuilder: (context, index) {
                final tarea = tareas[index];
                return ListTile(
                  title: Text(tarea.titulo),
                  subtitle: Text('Prioridad: ${tarea.prioridad}, Estimación: ${tarea.estimacion}h'),
                  trailing: Text(
                    '${tarea.fechaRegistro.day}/${tarea.fechaRegistro.month}/${tarea.fechaRegistro.year}',
                  ),
                );
              },
            ),
    );
  }
}
