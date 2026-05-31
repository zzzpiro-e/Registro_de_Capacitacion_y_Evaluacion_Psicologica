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
      'area': 'Tecnología',
      'informes': [], // Estructura lista para recibir múltiples PDFs
    },
    {
      'nombre': 'Ana Martínez Silva',
      'rut': '18.234.567-1',
      'motivo': 'Agotamiento',
      'estado': 'En Proceso',
      'fecha': '15 Mayo 2026',
      'cargo': 'Diseñadora UX',
      'area': 'Producto',
      'informes': [],
    },
    {
      'nombre': 'Roberto Fernández',
      'rut': '16.987.654-3',
      'motivo': 'Conflicto de Equipo',
      'estado': 'Completado',
      'fecha': '10 Mayo 2026',
      'cargo': 'Supervisor de Operaciones',
      'area': 'Logística',
      'informes': [],
    },
  ];

  // Métodos para obtener contadores dinámicos
  static int get countPendientes =>
      derivaciones.where((d) => d['estado'] == 'Pendiente').length;

  static int get countEnProceso =>
      derivaciones.where((d) => d['estado'] == 'En Proceso').length;

  static int get countCompletados =>
      derivaciones.where((d) => d['estado'] == 'Completado').length;

  /// Método para agregar un nuevo PDF en memoria a una derivación específica.
  /// Cuando implementes la Base de Datos, este método cambiará por una consulta INSERT / POST HTTP.
  static void agregarInforme({
    required String rut,
    required String nombreArchivo,
    required String rutaArchivo,
  }) {
    // Buscamos el mapa correspondiente al trabajador usando su RUT
    final index = derivaciones.indexWhere((d) => d['rut'] == rut);

    if (index != -1) {
      // Capturamos el momento exacto
      final ahora = DateTime.now();
      
      // Formateamos la fecha manualmente "DD-MM-YYYY HH:mm"
      final fechaFormateada = 
          "${ahora.day.toString().padLeft(2, '0')}-"
          "${ahora.month.toString().padLeft(2, '0')}-"
          "${ahora.year} "
          "${ahora.hour.toString().padLeft(2, '0')}:"
          "${ahora.minute.toString().padLeft(2, '0')}";

      // Añadimos el nuevo informe al inicio de la lista para cumplir con tu requerimiento
      // (así los nuevos quedan arriba), aunque luego en la interfaz también los ordenaremos.
      if (derivaciones[index]['informes'] == null) {
        derivaciones[index]['informes'] = [];
      }
      
      (derivaciones[index]['informes'] as List).add({
        'nombre_archivo': nombreArchivo,
        'ruta_archivo': rutaArchivo,
        'fecha_subida_raw': ahora, // Guardamos el DateTime puro para ordenamientos exactos
        'fecha_subida': fechaFormateada, // Para mostrar directamente en el diseño
      });
    }
  }
}