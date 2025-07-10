import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditarHistoriaPage extends StatefulWidget {
  final String id;
  final Map<String, dynamic> data;

  EditarHistoriaPage({required this.id, required this.data});

  @override
  _EditarHistoriaPageState createState() => _EditarHistoriaPageState();
}

class _EditarHistoriaPageState extends State<EditarHistoriaPage> {
  late TextEditingController _tituloController;
  late TextEditingController _descripcionController;
  late TextEditingController _criteriosController;
  late TextEditingController _estimacionController;
  String _prioridad = 'Media';

  @override
  void initState() {
    super.initState();
    _tituloController = TextEditingController(text: widget.data['titulo']);
    _descripcionController = TextEditingController(text: widget.data['descripcion']);
    _criteriosController = TextEditingController(text: widget.data['criterios']);
    _estimacionController = TextEditingController(text: widget.data['estimacion'].toString());
    _prioridad = widget.data['prioridad'] ?? 'Media';
  }

  void actualizarHistoria() async {
    final titulo = _tituloController.text.trim();
    final descripcion = _descripcionController.text.trim();
    final criterios = _criteriosController.text.trim();
    final estimacionStr = _estimacionController.text.trim();

    if (titulo.isEmpty || descripcion.isEmpty || criterios.isEmpty || estimacionStr.isEmpty) {
        mostrarError("Todos los campos son obligatorios.");
        return;
    }

    final estimacion = int.tryParse(estimacionStr);
    if (estimacion == null || estimacion <= 0) {
        mostrarError("La estimación debe ser un número entero positivo.");
        return;
    }

    await FirebaseFirestore.instance.collection('historias').doc(widget.id).update({
        'titulo': titulo,
        'descripcion': descripcion,
        'criterios': criterios,
        'estimacion': estimacion,
        'prioridad': _prioridad,
    });

    Navigator.pop(context);
  }

    void mostrarError(String mensaje) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(mensaje), backgroundColor: Colors.red),
        );
    }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Editar Historia')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: _tituloController,
              decoration: InputDecoration(labelText: 'Título'),
            ),
            TextField(
              controller: _descripcionController,
              decoration: InputDecoration(labelText: 'Descripción'),
              maxLines: 3,
            ),
            TextField(
              controller: _criteriosController,
              decoration: InputDecoration(labelText: 'Criterios de Aceptación'),
              maxLines: 3,
            ),
            TextField(
                controller: _estimacionController,
                decoration: InputDecoration(labelText: 'Estimación (horas)'),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly], // <-- Esto bloquea letras y decimales
                ),
            DropdownButtonFormField<String>(
              value: _prioridad,
              decoration: InputDecoration(labelText: 'Prioridad'),
              items: ['Alta', 'Media', 'Baja'].map((String value) {
                return DropdownMenuItem(value: value, child: Text(value));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _prioridad = value!;
                });
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: actualizarHistoria,
              child: Text('Guardar cambios'),
            ),
          ],
        ),
      ),
    );
  }
}