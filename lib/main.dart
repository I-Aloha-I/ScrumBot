import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class Tarea {
  final String titulo;
  final String prioridad;
  final double estimacion;
  final DateTime fechaRegistro;

  Tarea({
    required this.titulo,
    required this.prioridad,
    required this.estimacion,
    required this.fechaRegistro,
  });
}

class ChatMessage {
  final String texto;
  final bool esUsuario;

  ChatMessage({required this.texto, required this.esUsuario});
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestión de Tareas',
      home: const MainMenu(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainMenu extends StatelessWidget {
  const MainMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menú Principal'),
        backgroundColor: Colors.indigo,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ChatPage()),
                );
              },
              child: const Text("Abrir Chat"),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ListaTareasPage()),
                );
              },
              child: const Text("Abrir Lista de Tareas"),
            ),
          ],
        ),
      ),
    );
  }
}

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final List<ChatMessage> mensajes = [];
  final List<Tarea> listaTareas = [];
  final TextEditingController controlador = TextEditingController();

  // Estados del flujo
  String? tituloTemporal;
  String? prioridadTemporal;

  void enviarMensaje() {
    final texto = controlador.text.trim();
    if (texto.isEmpty) return;

    setState(() {
      mensajes.add(ChatMessage(texto: texto, esUsuario: true));
    });

    procesarEntrada(texto);
    controlador.clear();
  }

  void agregarMensaje(String texto, {bool esUsuario = false}) {
    setState(() {
      mensajes.add(ChatMessage(texto: texto, esUsuario: esUsuario));
    });
  }

  void procesarEntrada(String entrada) {
    if (tituloTemporal == null && entrada.toLowerCase().startsWith("agregar tarea:")) {
      tituloTemporal = entrada.substring(14).trim();
      agregarMensaje("¿Cuál es la prioridad de esta tarea? (Alta, Media, Baja)");
    } else if (tituloTemporal != null && prioridadTemporal == null) {
      final prioridad = entrada.toLowerCase();
      if (["alta", "media", "baja"].contains(prioridad)) {
        prioridadTemporal = prioridad[0].toUpperCase() + prioridad.substring(1); // Capitalizar
        agregarMensaje("¿Cuántas horas estimas que tomará esta tarea?");
      } else {
        agregarMensaje("Por favor indica una prioridad válida: Alta, Media o Baja.");
      }
    } else if (tituloTemporal != null && prioridadTemporal != null) {
      final horas = double.tryParse(entrada);
      if (horas != null && horas > 0) {
        final tarea = Tarea(
          titulo: tituloTemporal!,
          prioridad: prioridadTemporal!,
          estimacion: horas,
          fechaRegistro: DateTime.now(),
        );

        setState(() {
          listaTareas.add(tarea);
        });

        agregarMensaje("✅ Tarea registrada: ${tarea.titulo}, prioridad ${tarea.prioridad}, ${tarea.estimacion} horas.");
        // Reiniciar flujo
        tituloTemporal = null;
        prioridadTemporal = null;
      } else {
        agregarMensaje("Por favor ingresa una cantidad válida de horas.");
      }
    } else {
      agregarMensaje("🤖 Comando no reconocido. Para agregar una tarea escribe:\n\nAgregar tarea: [nombre de la tarea]");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
        backgroundColor: Colors.indigo,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: mensajes.length,
              itemBuilder: (context, index) {
                final mensaje = mensajes[index];
                return Container(
                  alignment: mensaje.esUsuario ? Alignment.centerRight : Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: mensaje.esUsuario ? Colors.indigo[200] : Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(mensaje.texto),
                  ),
                );
              },
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controlador,
                    onSubmitted: (_) => enviarMensaje(),
                    decoration: const InputDecoration(
                      hintText: 'Escribe un mensaje...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: enviarMensaje,
                  child: const Text("Enviar"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ListaTareasPage extends StatelessWidget {
  const ListaTareasPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Tareas'),
        backgroundColor: Colors.indigo,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Center(
        child: const Text("Aquí se mostrarán las tareas registradas"),
      ),
    );
  }
}
