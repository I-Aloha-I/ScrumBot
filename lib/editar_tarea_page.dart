import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditarTareaPage extends StatefulWidget {
  final String id;
  final Map<String, dynamic> data;

  EditarTareaPage({required this.id, required this.data});

  @override
  _EditarTareaPageState createState() => _EditarTareaPageState();
}

class _EditarTareaPageState extends State<EditarTareaPage> {
  late TextEditingController _tituloController;
  late TextEditingController _descripcionController;
  late TextEditingController _estimacionController;
  String? _prioridad;

  @override
  void initState() {
    super.initState();
    _tituloController = TextEditingController(text: widget.data['titulo']);
    _descripcionController = TextEditingController(text: widget.data['descripcion']);
    _estimacionController = TextEditingController(text: widget.data['estimacion'].toString());
    _prioridad = widget.data['prioridad'];
  }

  void _actualizarTarea() async {
    final titulo = _tituloController.text.trim();
    final descripcion = _descripcionController.text.trim();
    final estimacion = int.tryParse(_estimacionController.text.trim());

    if (titulo.isNotEmpty && descripcion.isNotEmpty && estimacion != null) {
      await FirebaseFirestore.instance.collection('tareas').doc(widget.id).update({
        'titulo': titulo,
        'descripcion': descripcion,
        'estimacion': estimacion,
        'prioridad': _prioridad,
      });
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Editar Tarea')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(controller: _tituloController, decoration: InputDecoration(labelText: 'Título')),
            TextField(controller: _descripcionController, decoration: InputDecoration(labelText: 'Descripción')),
            TextField(
              controller: _estimacionController,
              decoration: InputDecoration(labelText: 'Estimación (horas)'),
              keyboardType: TextInputType.number,
            ),
            DropdownButtonFormField<String>(
              value: _prioridad,
              decoration: InputDecoration(labelText: 'Prioridad'),
              items: ['Alta', 'Media', 'Baja']
                  .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                  .toList(),
              onChanged: (value) => setState(() => _prioridad = value),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _actualizarTarea,
              child: Text('Guardar Cambios'),
            ),
          ],
        ),
      ),
    );
  }
}