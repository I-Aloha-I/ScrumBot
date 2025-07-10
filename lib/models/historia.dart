class Historia {
  final String id;
  final String titulo;
  final String contenido;
  final DateTime fecha;

  Historia({
    required this.id,
    required this.titulo,
    required this.contenido,
    required this.fecha,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titulo': titulo,
      'contenido': contenido,
      'fecha': fecha.toIso8601String(),
    };
  }

  factory Historia.fromMap(Map<String, dynamic> map) {
    return Historia(
      id: map['id'],
      titulo: map['titulo'],
      contenido: map['contenido'],
      fecha: DateTime.parse(map['fecha']),
    );
  }
}
