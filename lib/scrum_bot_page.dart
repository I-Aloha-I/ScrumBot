import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'gemma_api_service.dart';

enum ConversationMode {
  preguntando,
  creandoTarea_PidiendoDescripcion,
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

  ConversationMode _modo = ConversationMode.preguntando;
  String? _tituloTemp;
  String? _descripcionTemp;
  String? _prioridadTemp;

  @override
  void initState() {
    super.initState();
    _mensajes.add(ChatMessage(
      texto:
          '¡Hola! Soy ScrumBot 🤖. Pregúntame sobre Scrum o escribe "agregar tarea: [tu tarea]". También puedo ayudarte con la priorización de tus historias escribiendo "sugerencia historias: [tu pregunta]".',
      esUsuario: false,
    ));
  }

  void _enviarMensaje() async {
    final texto = _controlador.text.trim();
    if (texto.isEmpty) return;

    final textoEnMinusculas = texto.toLowerCase();

    setState(() {
      _mensajes.add(ChatMessage(texto: texto, esUsuario: true));
    });
    _controlador.clear();

    final esPreguntaPriorizacion = RegExp(
      r'priorizar|ordenar|hacer primero|importante|backlog|dividir tareas|historias grandes|recomendación'
    ).hasMatch(textoEnMinusculas);

    // 1. Flujo de creación de tarea
    if (_modo != ConversationMode.preguntando) {
      _continuarCreacionTarea(texto);
    }

    // 2. Agregar tarea por comando
    else if (textoEnMinusculas.startsWith('agregar tarea:')) {
      _iniciarCreacionTarea(texto);
    }

    // 3. Sugerencia historias explícito (con o sin dos puntos)
    else if (textoEnMinusculas.startsWith('sugerencia historias')) {
      final pregunta = texto.substring('sugerencia historias'.length).trim();
      _obtenerSugerenciasDeHistorias(
        pregunta.isNotEmpty ? pregunta : "¿Cómo deberíamos priorizar las historias?"
      );
    }

    // 4. Detección por expresiones comunes
    else if (esPreguntaPriorizacion) {
      _obtenerSugerenciasDeHistorias(texto);
    }

    // 5. Pregunta general a ScrumBot
    else {
      _hacerPreguntaScrum(texto);
    }
  }

  void _iniciarCreacionTarea(String texto) {
    setState(() {
      _tituloTemp = texto.substring(15).trim();
      _modo = ConversationMode.creandoTarea_PidiendoDescripcion;
      _mensajes.add(ChatMessage(
        texto: 'Entendido. ¿Cuál es la descripción de la tarea?',
        esUsuario: false,
      ));
    });
  }

  void _continuarCreacionTarea(String texto) {
    setState(() {
      if (_modo == ConversationMode.creandoTarea_PidiendoDescripcion) {
        _descripcionTemp = texto;
        _modo = ConversationMode.creandoTarea_PidiendoPrioridad;
        _mensajes.add(ChatMessage(
            texto: 'Genial. ¿Y la prioridad? (Alta, Media, Baja)',
            esUsuario: false));
      } else if (_modo == ConversationMode.creandoTarea_PidiendoPrioridad) {
        if (['alta', 'media', 'baja'].contains(texto.toLowerCase())) {
          _prioridadTemp = texto;
          _modo = ConversationMode.creandoTarea_PidiendoEstimacion;
          _mensajes.add(ChatMessage(
              texto: 'Perfecto. ¿Cuántas horas estimas?', esUsuario: false));
        } else {
          _mensajes.add(ChatMessage(
              texto: 'Prioridad inválida. Responde Alta, Media o Baja.',
              esUsuario: false));
        }
      } else if (_modo == ConversationMode.creandoTarea_PidiendoEstimacion) {
        final horas = int.tryParse(texto);
        if (horas != null && horas > 0) {
          _guardarTareaEnFirebase(horas);
        } else {
          _mensajes.add(ChatMessage(
              texto: 'Introduce un número válido para las horas.',
              esUsuario: false));
        }
      }
    });
  }

  void _guardarTareaEnFirebase(int horas) async {
    final id = Uuid().v4();
    final nuevaTarea = {
      'id': id,
      'titulo': _tituloTemp!,
      'descripcion': _descripcionTemp!,
      'prioridad': _prioridadTemp!,
      'estimacion': horas,
      'fecha_registro': Timestamp.now(),
    };

    await FirebaseFirestore.instance.collection('tareas').doc(id).set(nuevaTarea);

    setState(() {
      _mensajes.add(ChatMessage(
        texto:
            '✅ ¡Tarea registrada en Firebase!\n📝 Título: $_tituloTemp\n🚦 Prioridad: $_prioridadTemp\n⏱️ Estimación: $horas horas.',
        esUsuario: false,
      ));
      _modo = ConversationMode.preguntando;
      _tituloTemp = null;
      _descripcionTemp = null;
      _prioridadTemp = null;
    });
  }

  Future<void> _obtenerSugerenciasDeHistorias(String pregunta) async {
    setState(() => _estaCargando = true);

    try {
      final snapshot = await FirebaseFirestore.instance.collection('historias').get();
      if (snapshot.docs.isEmpty) {
        setState(() {
          _mensajes.add(ChatMessage(
              texto: 'No hay historias en el Product Backlog para analizar.',
              esUsuario: false));
          _estaCargando = false;
        });
        return;
      }

      String contexto = "Estas son las historias en el Product Backlog:\n";
      for (var doc in snapshot.docs) {
        final data = doc.data();
        contexto +=
            "- Título: ${data['titulo']}, Descripción: ${data['descripcion']}, Prioridad: ${data['prioridad']}, Estimación: ${data['estimacion']} horas\n";
      }

      final prompt = "$contexto\n\nAhora responde a la pregunta: \"$pregunta\"";

      final respuesta = await ApiService.getScrumBotResponse(prompt);
      setState(() {
        _mensajes.add(ChatMessage(texto: respuesta, esUsuario: false));
      });
    } catch (e) {
      setState(() {
        _mensajes.add(ChatMessage(
            texto: 'Ocurrió un error al obtener las historias.',
            esUsuario: false));
      });
    } finally {
      setState(() => _estaCargando = false);
    }
  }

  void _hacerPreguntaScrum(String texto) async {
    setState(() => _estaCargando = true);
    final respuesta = await ApiService.getScrumBotResponse(texto);
    setState(() {
      _mensajes.add(ChatMessage(texto: respuesta, esUsuario: false));
      _estaCargando = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text('ScrumBot'),
        backgroundColor: Colors.deepPurple,
        leading: BackButton(color: Colors.white),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
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
              child: Row(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(width: 12),
                  Text("ScrumBot está escribiendo..."),
                ],
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
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(14),
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: msg.esUsuario ? Colors.deepPurple[200] : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomLeft:
                msg.esUsuario ? Radius.circular(16) : Radius.circular(0),
            bottomRight:
                msg.esUsuario ? Radius.circular(0) : Radius.circular(16),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: msg.esUsuario
            ? Text(
                msg.texto,
                style: TextStyle(color: Colors.white, fontSize: 15),
              )
            : MarkdownBody(data: msg.texto),
      ),
    );
  }

  Widget _buildChatInput() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controlador,
              decoration: InputDecoration(
                hintText: 'Pregunta o agrega una tarea...',
                filled: true,
                fillColor: Colors.grey[200],
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: (_) => _estaCargando ? null : _enviarMensaje(),
            ),
          ),
          SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: Colors.deepPurple,
            child: IconButton(
              icon: Icon(Icons.send, color: Colors.white),
              onPressed: _estaCargando ? null : _enviarMensaje,
            ),
          ),
        ],
      ),
    );
  }
}