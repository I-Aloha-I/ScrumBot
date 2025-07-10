import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'editar_historia_page.dart';

class VerHistoriasPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Historias Guardadas')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('historias').orderBy('fecha_creacion', descending: true).snapshots(),
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
                child: ListTile(
                  title: Text(historia['titulo'] ?? 'Sin título'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 4),
                      Text('Descripción: ${historia['descripcion'] ?? ''}'),
                      Text('Criterios: ${historia['criterios'] ?? ''}'),
                      Text('Estimación: ${historia['estimacion'] ?? ''}'),
                      Text('Prioridad: ${historia['prioridad'] ?? ''}'),
                      SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton(
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
                          child: Text('Editar'),
                        ),
                      )
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
