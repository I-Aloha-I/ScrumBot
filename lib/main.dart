import 'package:flutter/material.dart';
import 'tarea.dart'; // Importamos la clase Tarea

void main() {
  runApp(const MyApp());
}

// Lista global de tareas
List<Tarea> listaTareas = [];

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestor de Tareas',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const TareaScreen(),
    );
  }
}

class TareaScreen extends StatefulWidget {
  const TareaScreen({super.key});

  @override
  State<TareaScreen> createState() => _TareaScreenState();
}

class _TareaScreenState extends State<TareaScreen> {
  final _tituloController = TextEditingController();
  final _estimacionController = TextEditingController();
  String _prioridad = 'Alta';

  void _guardarTarea() {
    final titulo = _tituloController.text;
    final estimacion = int.tryParse(_estimacionController.text);

    if (titulo.isEmpty || estimacion == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa todos los campos correctamente')),
      );
      return;
    }

    final nuevaTarea = Tarea(
      titulo: titulo,
      prioridad: _prioridad,
      estimacionHoras: estimacion,
    );

    setState(() {
      listaTareas.add(nuevaTarea);
    });

    _tituloController.clear();
    _estimacionController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('✅ Tarea agregada: ${nuevaTarea.titulo}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agregar Tarea'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _tituloController,
              decoration: const InputDecoration(labelText: 'Título de la tarea'),
            ),
            TextField(
              controller: _estimacionController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Estimación (horas)'),
            ),
            DropdownButton<String>(
              value: _prioridad,
              onChanged: (String? nueva) {
                if (nueva != null) {
                  setState(() {
                    _prioridad = nueva;
                  });
                }
              },
              items: <String>['Alta', 'Media', 'Baja']
                  .map<DropdownMenuItem<String>>((String valor) {
                return DropdownMenuItem<String>(
                  value: valor,
                  child: Text(valor),
                );
              }).toList(),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _guardarTarea,
              child: const Text('Guardar Tarea'),
            ),
            const SizedBox(height: 20),
            const Text('Tareas registradas:'),
            Expanded(
              child: ListView.builder(
                itemCount: listaTareas.length,
                itemBuilder: (context, index) {
                  final tarea = listaTareas[index];
                  return ListTile(
                    title: Text(tarea.titulo),
                    subtitle: Text(
                      'Prioridad: ${tarea.prioridad}, Estimación: ${tarea.estimacionHoras}h',
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
