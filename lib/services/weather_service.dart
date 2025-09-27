import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/wind_data.dart';

class WeatherService {
  static const String baseUrl = 'https://www.datos.gov.co/api/v3/views/sgfv-3yp8/query.json';

  Future<List<WindData>> getWindData() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        
        // La API devuelve los datos en el campo 'data'
        final List<dynamic> dataList = jsonData['data'] ?? [];
        
        // Convertir cada elemento a WindData
        List<WindData> windDataList = dataList.map((item) {
          // Los datos vienen como array, necesitamos mapearlos a un objeto
          if (item is List && item.length >= 9) {
            return WindData.fromJson({
              'estacion': item[8],
              'departamento': item[9],
              'municipio': item[10],
              'fechaobservacion': item[11],
              'velocidadviento': item[12],
              'direccionviento': item[13],
              'temperatura': item[14],
              'humedad': item[15],
              'presion': item[16],
            });
          }
          return WindData();
        }).where((data) => data.estacion != null).toList();
        
        return windDataList;
      } else {
        throw Exception('Error al cargar datos: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
}