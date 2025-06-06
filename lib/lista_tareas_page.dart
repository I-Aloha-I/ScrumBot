import 'package:flutter/material.dart';
import 'tarea.dart';

class ListaTareasPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lista de Tareas'),
        leading: BackButton(onPressed: () => Navigator.pop(context)),
      ),
      body: ListView.builder(
        itemCount: tareas.length,
        itemBuilder: (context, index) {
          final t = tareas[index];
          return ListTile(
            title: Text(t.titulo),
            subtitle:
                Text("Prioridad: ${t.prioridad} | Estimación: ${t.estimacion} horas"),
            trailing: Text(
                "${t.fechaRegistro.day}/${t.fechaRegistro.month}/${t.fechaRegistro.year}"),
          );
        },
      ),
    );
  }
}