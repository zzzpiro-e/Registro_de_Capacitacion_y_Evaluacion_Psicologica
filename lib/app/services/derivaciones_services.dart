class DerivacionService {
  // Fuente única de verdad simulando la base de datos local
  static final List<Map<String, dynamic>> derivaciones = [
    {
      'nombre': 'Carlos Rodríguez López',
      'rut': '15.789.456-2',
      'motivo': 'Estrés Laboral',
      'estado': 'Pendiente',
      'fecha': '18 Mayo 2026',
      'cargo': 'Analista de Sistemas',
      'area': 'Tecnología'
    },
    {
      'nombre': 'Ana Martínez Silva',
      'rut': '18.234.567-1',
      'motivo': 'Agotamiento',
      'estado': 'En Proceso',
      'fecha': '15 Mayo 2026',
      'cargo': 'Diseñadora UX',
      'area': 'Producto'
    },
    {
      'nombre': 'Roberto Fernández',
      'rut': '16.987.654-3',
      'motivo': 'Conflicto de Equipo',
      'estado': 'Completado',
      'fecha': '10 Mayo 2026',
      'cargo': 'Supervisor de Operaciones',
      'area': 'Logística'
    },
  ];

  // Métodos para obtener contadores dinámicos
  static int get countPendientes =>
      derivaciones.where((d) => d['estado'] == 'Pendiente').length;

  static int get countEnProceso =>
      derivaciones.where((d) => d['estado'] == 'En Proceso').length;

  static int get countCompletados =>
      derivaciones.where((d) => d['estado'] == 'Completado').length;
}