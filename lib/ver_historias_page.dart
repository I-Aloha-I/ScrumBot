import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'editar_historia_page.dart';

class VerHistoriasPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Historias Guardadas')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('historias')
            .orderBy('fecha_creacion', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No hay historias guardadas.'));
          }

          final historias = snapshot.data!.docs;

          return ListView.builder(
            itemCount: historias.length,
            itemBuilder: (context, index) {
              final historia = historias[index].data() as Map<String, dynamic>;

              return Card(
                margin: EdgeInsets.all(10),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        historia['titulo'] ?? 'Sin título',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 6),
                      Text('Descripción: ${historia['descripcion'] ?? ''}'),
                      Text('Criterios: ${historia['criterios'] ?? ''}'),
                      Text('Estimación: ${historia['estimacion'] ?? ''}'),
                      Text('Prioridad: ${historia['prioridad'] ?? ''}'),
                      SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EditarHistoriaPage(
                                    id: historias[index].id,
                                    data: historia,
                                  ),
                                ),
                              );
                            },
                            icon: Icon(Icons.edit),
                            label: Text('Editar'),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                          ),
                          SizedBox(width: 10),
                          ElevatedButton.icon(
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text('Confirmar eliminación'),
                                  content: Text('¿Estás seguro de que deseas eliminar esta historia?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, false),
                                      child: Text('Cancelar'),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, true),
                                      child: Text('Eliminar'),
                                    ),
                                  ],
                                ),
                              );

                              if (confirm == true) {
                                await FirebaseFirestore.instance
                                    .collection('historias')
                                    .doc(historias[index].id)
                                    .delete();

                                // Mostrar SnackBar
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Historia eliminada con éxito'),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              }
                            },
                            icon: Icon(Icons.delete),
                            label: Text('Eliminar'),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
