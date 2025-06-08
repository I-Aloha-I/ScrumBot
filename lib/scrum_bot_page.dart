import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart'; // 1. Importamos el paquete
import 'gemma_api_service.dart';

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

  @override
  void initState() {
    super.initState();
    _mensajes.add(ChatMessage(
        texto:
            '¡Hola! Soy ScrumBot. ¿En qué puedo ayudarte hoy sobre la metodología Scrum?',
        esUsuario: false));
  }

  void _enviarMensaje() async {
    final texto = _controlador.text.trim();
    if (texto.isEmpty) return;

    _controlador.clear();
    setState(() {
      _mensajes.add(ChatMessage(texto: texto, esUsuario: true));
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

  // 2. ESTA ES LA FUNCIÓN QUE HEMOS MODIFICADO
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
        // Aquí está la lógica principal del cambio:
        child: msg.esUsuario
            // Si el mensaje es del usuario, usamos el widget Text normal.
            ? Text(msg.texto)
            // Si el mensaje es del bot, usamos MarkdownBody para renderizar el formato.
            : MarkdownBody(
                data: msg.texto,
                selectable: true, // Permite seleccionar y copiar el texto
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
                hintText: 'Pregunta algo sobre Scrum...',
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