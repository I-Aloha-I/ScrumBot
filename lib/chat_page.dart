import 'package:flutter/material.dart';
import 'tarea.dart';

class ChatMessage {
  final String texto;
  final bool esUsuario;

  ChatMessage({required this.texto, required this.esUsuario});
}

class ChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final List<ChatMessage> mensajes = [];
  final TextEditingController controlador = TextEditingController();

  String? tituloTemp;
  String? prioridadTemp;
  int? estimacionTemp;

  void procesarMensaje(String texto) {
    setState(() {
      mensajes.add(ChatMessage(texto: texto, esUsuario: true));
    });

    if (texto.toLowerCase().startsWith("agregar tarea:")) {
      tituloTemp = texto.substring(15).trim();
      prioridadTemp = null;
      estimacionTemp = null;

      setState(() {
        mensajes.add(ChatMessage(
            texto: "¿Cuál es la prioridad de esta tarea (Alta, Media, Baja)?",
            esUsuario: false));
      });
    } else if (["alta", "media", "baja"].contains(texto.toLowerCase())) {
      prioridadTemp = texto;

      setState(() {
        mensajes.add(ChatMessage(
            texto: "¿Cuántas horas estimas que tomará esta tarea?",
            esUsuario: false));
      });
    } else {
      int? horas = int.tryParse(texto);
      if (horas != null && tituloTemp != null && prioridadTemp != null) {
        estimacionTemp = horas;

        final nuevaTarea = Tarea(
          titulo: tituloTemp!,
          prioridad: prioridadTemp!,
          estimacion: estimacionTemp!,
          fechaRegistro: DateTime.now(),
        );

        tareas.add(nuevaTarea);

        setState(() {
          mensajes.add(ChatMessage(
              texto:
                  "Tarea registrada: ${nuevaTarea.titulo}, prioridad ${nuevaTarea.prioridad}, ${nuevaTarea.estimacion} horas.",
              esUsuario: false));
        });

        tituloTemp = null;
        prioridadTemp = null;
        estimacionTemp = null;
      } else {
        setState(() {
          mensajes.add(ChatMessage(
              texto:
                  "No entendí. Si estás registrando una tarea, indica prioridad o estimación.",
              esUsuario: false));
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat'),
        leading: BackButton(onPressed: () => Navigator.pop(context)),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: mensajes.length,
              itemBuilder: (context, index) {
                final msg = mensajes[index];
                return ListTile(
                  title: Align(
                    alignment:
                        msg.esUsuario ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: msg.esUsuario ? Colors.blue[100] : Colors.grey[300],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(msg.texto),
                    ),
                  ),
                );
              },
            ),
          ),
          Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controlador,
                    decoration: InputDecoration(
                      hintText: 'Escribe un mensaje...',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (texto) {
                      procesarMensaje(texto);
                      controlador.clear();
                    },
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    procesarMensaje(controlador.text);
                    controlador.clear();
                  },
                  child: Text("Enviar"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}