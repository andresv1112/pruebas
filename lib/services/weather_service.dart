import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/wind_data.dart';

class WeatherService {
  static const String baseUrl = 'https://www.datos.gov.co/api/v3/views/sgfv-3yp8/query.json';
  static const String appToken = '8xr6o5n2fu2bndgir6d0ircie';
  static const String apiKey = '37fclj0a0x0j4p9ax9h1dcdb31nec5je836r4141m4tzndtcza';

  Future<List<WindData>> getWindData() async {
    try {
      final uri = Uri.parse(baseUrl).replace(queryParameters: {
        '\$\$app_token': appToken,
      });
      
      final response = await http.get(
        uri,
        headers: {
          'X-App-Token': appToken,
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
      );
      
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
      } else if (response.statusCode == 403) {
        throw Exception('Error de autenticación: Verifica las API keys');
      } else if (response.statusCode == 429) {
        throw Exception('Límite de solicitudes excedido. Intenta más tarde');
      } else {
        throw Exception('Error al cargar datos: ${response.statusCode}');
      }
    } catch (e) {
      if (e.toString().contains('SocketException')) {
        throw Exception('Sin conexión a internet');
      } else if (e.toString().contains('TimeoutException')) {
        throw Exception('Tiempo de espera agotado');
      } else {
        throw Exception('Error de conexión: $e');
      }
    }
  }
}