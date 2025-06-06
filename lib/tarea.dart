class Tarea {
  final String titulo;
  final String prioridad;
  final int estimacion;
  final DateTime fechaRegistro;

  Tarea({
    required this.titulo,
    required this.prioridad,
    required this.estimacion,
    required this.fechaRegistro,
  });
}

List<Tarea> tareas = [];