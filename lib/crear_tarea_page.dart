import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class CrearTareaPage extends StatefulWidget {
  @override
  _CrearTareaPageState createState() => _CrearTareaPageState();
}

class _CrearTareaPageState extends State<CrearTareaPage> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _estimacionController = TextEditingController();
  String? _prioridadSeleccionada;

  void _guardarTarea() async {
    if (_formKey.currentState!.validate()) {
      final id = Uuid().v4();

      final tarea = {
        'id': id,
        'titulo': _tituloController.text.trim(),
        'descripcion': _descripcionController.text.trim(),
        'estimacion': int.parse(_estimacionController.text.trim()),
        'prioridad': _prioridadSeleccionada,
        'fecha_registro': Timestamp.now(),
      };

      try {
        await FirebaseFirestore.instance.collection('tareas').doc(id).set(tarea);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tarea guardada correctamente')),
        );

        Navigator.pop(context, true); // Regresar indicando que se guardó
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar la tarea: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Crear Nueva Tarea')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _tituloController,
                decoration: InputDecoration(labelText: 'Título'),
                validator: (value) => value!.isEmpty ? 'Campo obligatorio' : null,
              ),
              TextFormField(
                controller: _descripcionController,
                decoration: InputDecoration(labelText: 'Descripción'),
                validator: (value) => value!.isEmpty ? 'Campo obligatorio' : null,
              ),
              TextFormField(
                controller: _estimacionController,
                decoration: InputDecoration(labelText: 'Estimación (horas)'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value!.isEmpty) return 'Campo obligatorio';
                  if (int.tryParse(value) == null || int.parse(value) <= 0) return 'Número no válido';
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
                validator: (value) => value == null ? 'Selecciona una prioridad' : null,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _guardarTarea,
                child: Text('Guardar Tarea'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}