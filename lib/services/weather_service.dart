import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/wind_data.dart';

class WeatherService {
  static const String baseUrl =
      'https://www.datos.gov.co/api/v3/views/sgfv-3yp8/query.json';
  static const String appToken = 'FMY120k5usxrMjkb8hGs3LpfB';

  final http.Client _client;

  WeatherService({http.Client? client}) : _client = client ?? http.Client();

  Future<List<WindData>> getWindData({String? department}) async {
    try {
      final Map<String, String> queryParameters = {
        'limit': '200',
        r'$order': 'fecha DESC',
      };

      if (department != null && department.trim().isNotEmpty) {
        final normalized = department.trim().toUpperCase().replaceAll("'", "''");
        queryParameters[r'$where'] = "upper(departamento)='$normalized'";
      }

      final uri = Uri.parse(baseUrl).replace(queryParameters: queryParameters);

      final response = await _client.get(
        uri,
        headers: {
          'X-App-Token': appToken,
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Error al cargar datos: ${response.statusCode}');
      }

      final Map<String, dynamic> jsonData = json.decode(response.body);
      final List<dynamic> dataList = (jsonData['data'] as List<dynamic>?) ?? [];

      final windDataList = dataList
          .whereType<List>()
          .map((row) => WindData.fromRow(row))
          .toList();

      return windDataList;
    } catch (e) {
      final message = e.toString();
      if (message.contains('SocketException')) {
        throw Exception('Sin conexión a internet');
      }
      if (message.contains('TimeoutException')) {
        throw Exception('Tiempo de espera agotado');
      }
      throw Exception('Error de conexión: $e');
    }
  }
}
