class Tarea {
  final String titulo;
  final String prioridad;
  final int estimacionHoras;
  final DateTime fechaRegistro;

  Tarea({
    required this.titulo,
    required this.prioridad,
    required this.estimacionHoras,
  }) : fechaRegistro = DateTime.now();

  @override
  String toString() {
    return 'Tarea: $titulo, Prioridad: $prioridad, Estimación: $estimacionHoras horas, Fecha: $fechaRegistro';
  }
}
