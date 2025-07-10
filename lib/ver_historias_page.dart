import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'editar_historia_page.dart';

class VerHistoriasPage extends StatefulWidget {
  @override
  _VerHistoriasPageState createState() => _VerHistoriasPageState();
}

class _VerHistoriasPageState extends State<VerHistoriasPage> {
  String _ordenSeleccionado = 'prioridad_asc';
  List<DocumentSnapshot> _historias = [];

  @override
  void initState() {
    super.initState();
    _cargarHistorias();
  }

  Future<void> _cargarHistorias() async {
    final snapshot = await FirebaseFirestore.instance.collection('historias').get();
    setState(() {
      _historias = snapshot.docs;
      _ordenarHistorias();
    });
  }

  void _ordenarHistorias() {
    _historias.sort((a, b) {
      final dataA = a.data() as Map<String, dynamic>;
      final dataB = b.data() as Map<String, dynamic>;

      switch (_ordenSeleccionado) {
        case 'prioridad_asc':
          return _valorPrioridad(dataA['prioridad']).compareTo(_valorPrioridad(dataB['prioridad']));
        case 'prioridad_desc':
          return _valorPrioridad(dataB['prioridad']).compareTo(_valorPrioridad(dataA['prioridad']));
        case 'estimacion_asc':
          return (int.tryParse('${dataA['estimacion']}') ?? 0).compareTo(int.tryParse('${dataB['estimacion']}') ?? 0);
        case 'estimacion_desc':
          return (int.tryParse('${dataB['estimacion']}') ?? 0).compareTo(int.tryParse('${dataA['estimacion']}') ?? 0);
        case 'titulo':
          return (dataA['titulo'] ?? '').toLowerCase().compareTo((dataB['titulo'] ?? '').toLowerCase());
        default:
          return 0;
      }
    });
  }

  int _valorPrioridad(String? prioridad) {
    switch (prioridad) {
      case 'Alta':
        return 1;
      case 'Media':
        return 2;
      case 'Baja':
        return 3;
      default:
        return 4;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Historias Guardadas')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: DropdownButton<String>(
              value: _ordenSeleccionado,
              onChanged: (value) {
                setState(() {
                  _ordenSeleccionado = value!;
                  _ordenarHistorias();
                });
              },
              items: [
                DropdownMenuItem(value: 'prioridad_asc', child: Text('Prioridad (Ascendente)')),
                DropdownMenuItem(value: 'prioridad_desc', child: Text('Prioridad (Descendente)')),
                DropdownMenuItem(value: 'estimacion_asc', child: Text('Estimación (Ascendente)')),
                DropdownMenuItem(value: 'estimacion_desc', child: Text('Estimación (Descendente)')),
                DropdownMenuItem(value: 'titulo', child: Text('Título (A-Z)')),
              ],
            ),
          ),
          Expanded(
            child: _historias.isEmpty
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: _historias.length,
                    itemBuilder: (context, index) {
                      final doc = _historias[index];
                      final historia = doc.data() as Map<String, dynamic>;

                      return Card(
                        margin: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        child: ListTile(
                          title: Text(historia['titulo'] ?? 'Sin título'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 4),
                              Text('Descripción: ${historia['descripcion'] ?? ''}'),
                              Text('Criterios: ${historia['criterios'] ?? ''}'),
                              Text('Estimación: ${historia['estimacion']} h'),
                              Text('Prioridad: ${historia['prioridad'] ?? ''}'),
                              SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton(
                                    child: Text('Editar'),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => EditarHistoriaPage(
                                            id: doc.id,
                                            data: historia,
                                          ),
                                        ),
                                      ).then((_) => _cargarHistorias());
                                    },
                                  ),
                                  SizedBox(width: 8),
                                  TextButton(
                                    child: Text('Eliminar', style: TextStyle(color: Colors.red)),
                                    onPressed: () async {
                                      await FirebaseFirestore.instance.collection('historias').doc(doc.id).delete();
                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                        content: Text('Historia eliminada.'),
                                      ));
                                      _cargarHistorias();
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
