import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'gemma_api_service.dart';
import 'tarea.dart'; // Necesitamos acceso a la clase Tarea y la lista de tareas

// Enum para controlar el modo de la conversación (preguntando o creando tarea)
enum ConversationMode {
  preguntando,
  creandoTarea_PidiendoPrioridad,
  creandoTarea_PidiendoEstimacion
}

class ChatMessage {
  final String texto;
  final bool esUsuario;

  ChatMessage({required this.texto, required this.esUsuario});
}

class ScrumBotPage extends StatefulWidget {
  @override
  _ScrumBotPageState createState() => _ScrumBotPageState();
}

class _ScrumBotPageState extends State<ScrumBotPage> {
  final List<ChatMessage> _mensajes = [];
  final TextEditingController _controlador = TextEditingController();
  bool _estaCargando = false;

  // --- NUEVOS ESTADOS PARA CONTROLAR LA CREACIÓN DE TAREAS ---
  ConversationMode _modo = ConversationMode.preguntando;
  String? _tituloTemp;
  String? _prioridadTemp;
  // --- FIN DE NUEVOS ESTADOS ---

  @override
  void initState() {
    super.initState();
    _mensajes.add(ChatMessage(
        texto:
            '¡Hola! Soy ScrumBot. Pregúntame sobre Scrum o añade una tarea escribiendo "agregar tarea: [tu tarea]".',
        esUsuario: false));
  }

  // --- LÓGICA PRINCIPAL MODIFICADA ---
  void _enviarMensaje() async {
    final texto = _controlador.text.trim();
    if (texto.isEmpty) return;

    final textoEnMinusculas = texto.toLowerCase();

    // Añadimos el mensaje del usuario a la lista
    setState(() {
      _mensajes.add(ChatMessage(texto: texto, esUsuario: true));
    });
    _controlador.clear();

    // --- DECIDIMOS QUÉ HACER CON EL MENSAJE ---

    // Expresión regular para detectar preguntas sobre priorización
    final esPreguntaPriorizacion = RegExp(r'priorizar|dividir|ordenar|qué historias hacer primero|historias muy grandes').hasMatch(textoEnMinusculas);

    // 1. Si estamos en medio de la creación de una tarea, continuamos ese flujo.
    if (_modo != ConversationMode.preguntando) {
      _continuarCreacionTarea(textoEnMinusculas);
    }
    // 2. Si el usuario quiere agregar una nueva tarea.
    else if (textoEnMinusculas.startsWith('agregar tarea:')) {
      _iniciarCreacionTarea(texto);
    }
    // NUEVO: 3. Si es una pregunta sobre priorización de historias.
    else if (esPreguntaPriorizacion) {
      _obtenerSugerenciasDeHistorias(texto);
    }
    // 4. Si es cualquier otro mensaje, lo tratamos como una pregunta para la IA.
    else {
      _hacerPreguntaScrum(texto);
    }
  }

  void _iniciarCreacionTarea(String texto) {
    setState(() {
      _tituloTemp = texto.substring(15).trim();
      _modo = ConversationMode.creandoTarea_PidiendoPrioridad;
      _mensajes.add(ChatMessage(
          texto: 'Entendido. ¿Cuál es la prioridad de la tarea? (Alta, Media, Baja)',
          esUsuario: false));
    });
  }

  void _continuarCreacionTarea(String texto) {
    if (_modo == ConversationMode.creandoTarea_PidiendoPrioridad) {
      if (['alta', 'media', 'baja'].contains(texto)) {
        setState(() {
          _prioridadTemp = texto;
          _modo = ConversationMode.creandoTarea_PidiendoEstimacion;
          _mensajes.add(ChatMessage(
              texto: 'Perfecto. ¿Cuántas horas estimas para esta tarea?',
              esUsuario: false));
        });
      } else {
        setState(() {
          _mensajes.add(ChatMessage(
              texto: 'Prioridad no válida. Por favor, responde Alta, Media o Baja.',
              esUsuario: false));
        });
      }
    } else if (_modo == ConversationMode.creandoTarea_PidiendoEstimacion) {
      int? horas = int.tryParse(texto);
      if (horas != null) {
        final nuevaTarea = Tarea(
          titulo: _tituloTemp!,
          prioridad: _prioridadTemp!,
          estimacion: horas,
          fechaRegistro: DateTime.now(),
        );
        tareas.add(nuevaTarea); // Añadimos la tarea a la lista global

        setState(() {
          _mensajes.add(ChatMessage(
              texto:
                  '¡Tarea registrada con éxito!\nTítulo: ${_tituloTemp!}\nPrioridad: ${_prioridadTemp!}\nEstimación: $horas horas.',
              esUsuario: false));
          // Reseteamos el modo para la siguiente conversación
          _modo = ConversationMode.preguntando;
          _tituloTemp = null;
          _prioridadTemp = null;
        });
      } else {
        setState(() {
          _mensajes.add(ChatMessage(
              texto: 'Por favor, introduce un número válido para las horas.',
              esUsuario: false));
        });
      }
    }
  }

  void _hacerPreguntaScrum(String texto) async {
    setState(() {
      _estaCargando = true;
    });

    final respuesta = await ApiService.getScrumBotResponse(texto);
    setState(() {
      _mensajes.add(ChatMessage(texto: respuesta, esUsuario: false));
      _estaCargando = false;
    });
  }

  // --- NUEVA FUNCIÓN PARA OBTENER SUGERENCIAS ---
  Future<void> _obtenerSugerenciasDeHistorias(String pregunta) async {
    setState(() {
      _estaCargando = true;
    });

    try {
      final snapshot = await FirebaseFirestore.instance.collection('historias').get();
      if (snapshot.docs.isEmpty) {
        setState(() {
          _mensajes.add(ChatMessage(texto: 'No hay historias en el Product Backlog para analizar.', esUsuario: false));
          _estaCargando = false;
        });
        return;
      }

      String contextoHistorias = "Aquí tienes una lista de historias de usuario del Product Backlog:\n";
      for (var doc in snapshot.docs) {
        final data = doc.data();
        contextoHistorias += "- Título: ${data['titulo']}, Descripción: ${data['descripcion']}, Prioridad: ${data['prioridad']}, Estimación: ${data['estimacion']} horas\n";
      }

      final promptCompleto = "$contextoHistorias\n\nBasado en estas historias, responde a la siguiente pregunta del usuario: \"$pregunta\"";

      final respuesta = await ApiService.getScrumBotResponse(promptCompleto);
      setState(() {
        _mensajes.add(ChatMessage(texto: respuesta, esUsuario: false));
      });

    } catch (e) {
      setState(() {
        _mensajes.add(ChatMessage(texto: 'Ocurrió un error al obtener las historias. Inténtalo de nuevo.', esUsuario: false));
      });
    } finally {
      setState(() {
        _estaCargando = false;
      });
    }
  }
  // --- FIN DE LA NUEVA FUNCIÓN ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ScrumBot'),
        leading: BackButton(onPressed: () => Navigator.pop(context)),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: _mensajes.length,
              itemBuilder: (context, index) {
                final msg = _mensajes[index];
                return _buildMessageBubble(msg);
              },
            ),
          ),
          if (_estaCargando)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(width: 10),
                    Text("ScrumBot está pensando...")
                  ],
                ),
              ),
            ),
          Divider(height: 1),
          _buildChatInput(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage msg) {
    return Align(
      alignment: msg.esUsuario ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 8.0),
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
        decoration: BoxDecoration(
          color: msg.esUsuario ? Colors.blue[100] : Colors.grey[300],
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: msg.esUsuario
            ? Text(msg.texto)
            : MarkdownBody(
                data: msg.texto,
                selectable: true,
              ),
      ),
    );
  }

  Widget _buildChatInput() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controlador,
              decoration: InputDecoration(
                hintText: 'Pregunta o agrega una tarea...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
              ),
              onSubmitted: (texto) => _estaCargando ? null : _enviarMensaje(),
            ),
          ),
          SizedBox(width: 8),
          IconButton(
            icon: Icon(Icons.send),
            onPressed: _estaCargando ? null : _enviarMensaje,
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.all(15),
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}