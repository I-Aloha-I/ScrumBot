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
  final _formKey = GlobalKey<FormState>();
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
    if (_formKey.currentState!.validate()) {
      final titulo = _tituloController.text.trim();
      final descripcion = _descripcionController.text.trim();
      final estimacion = int.parse(_estimacionController.text.trim());

      try {
        await FirebaseFirestore.instance
            .collection('tareas')
            .doc(widget.id)
            .update({
          'titulo': titulo,
          'descripcion': descripcion,
          'estimacion': estimacion,
          'prioridad': _prioridad,
        });
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tarea actualizada correctamente')),
        );
        Navigator.pop(context, true);
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al actualizar la tarea: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar Tarea')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                  controller: _tituloController,
                  decoration: const InputDecoration(labelText: 'Título'),
                  validator: (value) =>
                      value!.isEmpty ? 'Campo obligatorio' : null),
              TextFormField(
                  controller: _descripcionController,
                  decoration: const InputDecoration(labelText: 'Descripción'),
                  validator: (value) =>
                      value!.isEmpty ? 'Campo obligatorio' : null),
              TextFormField(
                controller: _estimacionController,
                decoration:
                    const InputDecoration(labelText: 'Estimación (horas)'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Campo obligatorio';
                  }
                  final n = int.tryParse(value);
                  if (n == null) {
                    return 'Introduce un número válido.';
                  }
                  if (n <= 0) {
                    return 'La estimación debe ser un número positivo.';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                value: _prioridad,
                decoration: const InputDecoration(labelText: 'Prioridad'),
                items: ['Alta', 'Media', 'Baja']
                    .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                    .toList(),
                onChanged: (value) => setState(() => _prioridad = value),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _actualizarTarea,
                child: const Text('Guardar Cambios'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}