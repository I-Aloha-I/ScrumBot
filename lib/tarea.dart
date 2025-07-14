import 'package:cloud_firestore/cloud_firestore.dart';

class Tarea {
  final String id;
  final String titulo;
  final String descripcion;
  final String prioridad;
  final int estimacion;
  final DateTime fechaRegistro;

  Tarea({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.prioridad,
    required this.estimacion,
    required this.fechaRegistro,
  });

  // Convierte un objeto Tarea a un mapa para Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titulo': titulo,
      'descripcion': descripcion,
      'prioridad': prioridad,
      'estimacion': estimacion,
      'fecha_registro': Timestamp.fromDate(fechaRegistro),
    };
  }

  // Crea un objeto Tarea desde un mapa de Firestore
  factory Tarea.fromMap(Map<String, dynamic> map) {
    return Tarea(
      id: map['id'],
      titulo: map['titulo'],
      descripcion: map['descripcion'],
      prioridad: map['prioridad'],
      estimacion: map['estimacion'],
      fechaRegistro: (map['fecha_registro'] as Timestamp).toDate(),
    );
  }
}