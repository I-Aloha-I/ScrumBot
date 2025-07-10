import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class CrearHistoriaPage extends StatefulWidget {
  @override
  _CrearHistoriaPageState createState() => _CrearHistoriaPageState();
}

class _CrearHistoriaPageState extends State<CrearHistoriaPage> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _criteriosController = TextEditingController();
  final _estimacionController = TextEditingController();
  String? _prioridadSeleccionada;

  void _guardarHistoria() async {
    if (_formKey.currentState!.validate()) {
      final id = Uuid().v4();

      final historia = {
        'id': id,
        'titulo': _tituloController.text.trim(),
        'descripcion': _descripcionController.text.trim(),
        'criterios': _criteriosController.text.trim(),
        'estimacion': double.parse(_estimacionController.text.trim()),
        'prioridad': _prioridadSeleccionada ?? 'No asignada',
        'fecha_creacion': DateTime.now().toIso8601String(),
      };

      try {
        await FirebaseFirestore.instance
            .collection('historias')
            .doc(id) // ✅ se asegura que sea tipo String
            .set(historia);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Historia guardada correctamente')),
        );

        _formKey.currentState!.reset();
        _tituloController.clear();
        _descripcionController.clear();
        _criteriosController.clear();
        _estimacionController.clear();
        setState(() => _prioridadSeleccionada = null);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar historia: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Crear Historia de Usuario')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _tituloController,
                decoration: InputDecoration(labelText: 'Título'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Este campo es obligatorio';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descripcionController,
                decoration: InputDecoration(labelText: 'Descripción'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Este campo es obligatorio';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _criteriosController,
                decoration: InputDecoration(labelText: 'Criterios de Aceptación'),
                maxLines: 3,
              ),
              TextFormField(
                controller: _estimacionController,
                decoration: InputDecoration(labelText: 'Estimación (en horas)'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Este campo es obligatorio';
                  }
                  if (double.tryParse(value.trim()) == null || double.parse(value.trim()) <= 0) {
                    return 'Debe ser un número positivo';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                value: _prioridadSeleccionada,
                decoration: InputDecoration(labelText: 'Prioridad'),
                items: ['Alta', 'Media', 'Baja']
                    .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                    .toList(),
                onChanged: (value) => setState(() => _prioridadSeleccionada = value),
                validator: (value) {
                  if (value == null) return 'Selecciona una prioridad';
                  return null;
                },
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _guardarHistoria,
                child: Text('Guardar Historia'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
