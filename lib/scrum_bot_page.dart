import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'gemma_api_service.dart';
import 'tarea.dart';

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

  ConversationMode _modo = ConversationMode.preguntando;
  String? _tituloTemp;
  String? _prioridadTemp;

  @override
  void initState() {
    super.initState();
    _mensajes.add(ChatMessage(
      texto:
          '¡Hola! Soy ScrumBot 🤖. Pregúntame sobre Scrum o escribe "agregar tarea: [tu tarea]".',
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

    if (_modo != ConversationMode.preguntando) {
      _continuarCreacionTarea(textoEnMinusculas);
    } else if (textoEnMinusculas.startsWith('agregar tarea:')) {
      _iniciarCreacionTarea(texto);
    } else {
      _hacerPreguntaScrum(texto);
    }
  }

  void _iniciarCreacionTarea(String texto) {
    setState(() {
      _tituloTemp = texto.substring(15).trim();
      _modo = ConversationMode.creandoTarea_PidiendoPrioridad;
      _mensajes.add(ChatMessage(
        texto: 'Entendido. ¿Cuál es la prioridad de la tarea? (Alta, Media, Baja)',
        esUsuario: false,
      ));
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
            esUsuario: false,
          ));
        });
      } else {
        setState(() {
          _mensajes.add(ChatMessage(
            texto: 'Prioridad no válida. Por favor, responde Alta, Media o Baja.',
            esUsuario: false,
          ));
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
        tareas.add(nuevaTarea);
        setState(() {
          _mensajes.add(ChatMessage(
            texto:
                '✅ ¡Tarea registrada!\n📝 Título: ${_tituloTemp!}\n🚦 Prioridad: ${_prioridadTemp!}\n⏱️ Estimación: $horas horas.',
            esUsuario: false,
          ));
          _modo = ConversationMode.preguntando;
          _tituloTemp = null;
          _prioridadTemp = null;
        });
      } else {
        setState(() {
          _mensajes.add(ChatMessage(
            texto: 'Por favor, introduce un número válido para las horas.',
            esUsuario: false,
          ));
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
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: msg.esUsuario ? Colors.deepPurple[200] : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomLeft: msg.esUsuario ? Radius.circular(16) : Radius.circular(0),
            bottomRight: msg.esUsuario ? Radius.circular(0) : Radius.circular(16),
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
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
