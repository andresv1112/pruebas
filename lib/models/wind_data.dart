class WindData {
  static const int codigoIndex = 0;
  static const int fechaIndex = 1;
  static const int velocidadIndex = 2;
  static const int departamentoIndex = 3;
  static const int municipioIndex = 4;
  static const int estacionIndex = 5;
  static const int latitudIndex = 6;
  static const int longitudIndex = 7;
  static const int direccionIndex = 8;
  static const int temperaturaIndex = 9;
  static const int humedadIndex = 10;
  static const int presionIndex = 11;

  final String? codigo;
  final String? estacion;
  final String? departamento;
  final String? municipio;
  final DateTime? fechaObservacion;
  final double? velocidadViento;
  final String? direccionViento;
  final double? temperatura;
  final double? humedad;
  final double? presion;
  final double? latitud;
  final double? longitud;

  const WindData({
    this.codigo,
    this.estacion,
    this.departamento,
    this.municipio,
    this.fechaObservacion,
    this.velocidadViento,
    this.direccionViento,
    this.temperatura,
    this.humedad,
    this.presion,
    this.latitud,
    this.longitud,
  });

  factory WindData.fromRow(List<dynamic> row) {
    String? stringAt(int index) {
      if (index >= row.length) return null;
      final value = row[index];
      if (value == null) return null;
      final text = value.toString().trim();
      return text.isEmpty ? null : text;
    }

    double? doubleAt(int index) {
      final value = stringAt(index);
      if (value == null) return null;
      final normalized = value.replaceAll(',', '.');
      return double.tryParse(normalized);
    }

    DateTime? dateAt(int index) {
      final value = stringAt(index);
      if (value == null) return null;
      return DateTime.tryParse(value);
    }

    return WindData(
      codigo: stringAt(codigoIndex),
      fechaObservacion: dateAt(fechaIndex),
      velocidadViento: doubleAt(velocidadIndex),
      departamento: stringAt(departamentoIndex),
      municipio: stringAt(municipioIndex),
      estacion: stringAt(estacionIndex),
      latitud: doubleAt(latitudIndex),
      longitud: doubleAt(longitudIndex),
      direccionViento: stringAt(direccionIndex),
      temperatura: doubleAt(temperaturaIndex),
      humedad: doubleAt(humedadIndex),
      presion: doubleAt(presionIndex),
    );
  }
}
