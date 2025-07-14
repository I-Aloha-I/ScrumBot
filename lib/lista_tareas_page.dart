import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'crear_tarea_page.dart';
import 'editar_tarea_page.dart';

class ListaTareasPage extends StatefulWidget {
  @override
  _ListaTareasPageState createState() => _ListaTareasPageState();
}

class _ListaTareasPageState extends State<ListaTareasPage> {
  Future<void> _eliminarTarea(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirmar'),
        content: Text('¿Seguro que quieres eliminar esta tarea?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text('Eliminar')),
        ],
      ),
    );

    if (confirm == true) {
      await FirebaseFirestore.instance.collection('tareas').doc(id).delete();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lista de Tareas'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('tareas').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

          final tareas = snapshot.data!.docs;

          return ListView.builder(
            itemCount: tareas.length,
            itemBuilder: (context, index) {
              final tarea = tareas[index].data() as Map<String, dynamic>;
              final tareaId = tareas[index].id;

              return Card(
                margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  title: Text(tarea['titulo']),
                  subtitle: Text(
                    'Prioridad: ${tarea['prioridad']} | Estimación: ${tarea['estimacion']}h\nDescripción: ${tarea['descripcion']}',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.blue),
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EditarTareaPage(id: tareaId, data: tarea),
                            ),
                          );
                          if (result == true) setState(() {});
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _eliminarTarea(tareaId),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => CrearTareaPage()),
          );
          if (result == true) setState(() {});
        },
        child: Icon(Icons.add),
        tooltip: 'Crear Tarea',
      ),
    );
  }
}