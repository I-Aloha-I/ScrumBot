import 'package:flutter/material.dart';

class CrearHistoriaPage extends StatefulWidget {
  const CrearHistoriaPage({super.key});

  @override
  State<CrearHistoriaPage> createState() => _CrearHistoriaPageState();
}

class _CrearHistoriaPageState extends State<CrearHistoriaPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController tituloController = TextEditingController();
  final TextEditingController descripcionController = TextEditingController();
  final TextEditingController criteriosController = TextEditingController();
  final TextEditingController estimacionController = TextEditingController();

  String prioridadSeleccionada = 'Media';

  void _guardarHistoria() {
    if (_formKey.currentState!.validate()) {
      final titulo = tituloController.text.trim();
      final descripcion = descripcionController.text.trim();
      final criterios = criteriosController.text.trim();
      final estimacion = estimacionController.text.trim();
      final prioridad = prioridadSeleccionada;

      // Por ahora, solo mostramos los datos (luego se integrará con Firebase)
      print('Historia registrada:');
      print('Título: $titulo');
      print('Descripción: $descripcion');
      print('Criterios: $criterios');
      print('Estimación: $estimacion horas');
      print('Prioridad: $prioridad');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Historia registrada: $titulo')),
      );

      // Limpiar campos (opcional)
      tituloController.clear();
      descripcionController.clear();
      criteriosController.clear();
      estimacionController.clear();
      setState(() {
        prioridadSeleccionada = 'Media';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crear Historia de Usuario')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: tituloController,
                decoration: const InputDecoration(labelText: 'Título'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Campo obligatorio' : null,
              ),
              TextFormField(
                controller: descripcionController,
                decoration: const InputDecoration(labelText: 'Descripción'),
                maxLines: 2,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Campo obligatorio' : null,
              ),
              TextFormField(
                controller: criteriosController,
                decoration: const InputDecoration(labelText: 'Criterios de aceptación'),
                maxLines: 2,
              ),
              TextFormField(
                controller: estimacionController,
                decoration: const InputDecoration(labelText: 'Estimación (horas)'),
                keyboardType: TextInputType.number,
              ),
              DropdownButtonFormField<String>(
                value: prioridadSeleccionada,
                decoration: const InputDecoration(labelText: 'Prioridad'),
                items: ['Alta', 'Media', 'Baja']
                    .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      prioridadSeleccionada = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _guardarHistoria,
                child: const Text('Guardar historia'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
