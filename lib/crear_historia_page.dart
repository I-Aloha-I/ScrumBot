import 'package:flutter/material.dart';

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

  void _guardarHistoria() {
    if (_formKey.currentState!.validate()) {
      final titulo = _tituloController.text.trim();
      final descripcion = _descripcionController.text.trim();
      final criterios = _criteriosController.text.trim();
      final estimacion = _estimacionController.text.trim();
      final prioridad = _prioridadSeleccionada ?? 'No asignada';

      print('Historia registrada:');
      print('Título: $titulo');
      print('Descripción: $descripcion');
      print('Criterios: $criterios');
      print('Estimación: $estimacion horas');
      print('Prioridad: $prioridad');

      // Aquí podrías guardar en Firebase, por ahora solo mostramos un mensaje:
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Historia registrada correctamente')),
      );

      _formKey.currentState!.reset();
      _tituloController.clear();
      _descripcionController.clear();
      _criteriosController.clear();
      _estimacionController.clear();
      setState(() => _prioridadSeleccionada = null);
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
              SizedBox(height: 16),
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
