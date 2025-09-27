class WindData {
  final String? estacion;
  final String? departamento;
  final String? municipio;
  final DateTime? fechaObservacion;
  final double? velocidadViento;
  final String? direccionViento;
  final double? temperatura;
  final double? humedad;
  final double? presion;

  WindData({
    this.estacion,
    this.departamento,
    this.municipio,
    this.fechaObservacion,
    this.velocidadViento,
    this.direccionViento,
    this.temperatura,
    this.humedad,
    this.presion,
  });

  factory WindData.fromJson(Map<String, dynamic> json) {
    return WindData(
      estacion: json['estacion']?.toString(),
      departamento: json['departamento']?.toString(),
      municipio: json['municipio']?.toString(),
      fechaObservacion: json['fechaobservacion'] != null 
          ? DateTime.tryParse(json['fechaobservacion'].toString())
          : null,
      velocidadViento: json['velocidadviento'] != null 
          ? double.tryParse(json['velocidadviento'].toString())
          : null,
      direccionViento: json['direccionviento']?.toString(),
      temperatura: json['temperatura'] != null 
          ? double.tryParse(json['temperatura'].toString())
          : null,
      humedad: json['humedad'] != null 
          ? double.tryParse(json['humedad'].toString())
          : null,
      presion: json['presion'] != null 
          ? double.tryParse(json['presion'].toString())
          : null,
    );
  }
}