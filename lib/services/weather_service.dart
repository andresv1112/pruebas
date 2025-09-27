import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/weather_data.dart';

/// TODO: Cargar la API key de forma segura (por ejemplo, mediante variables de
/// entorno o un servicio de configuración remoto).
const String openWeatherApiKey = '30bd83a1dbab5a9153f29627378ca245';

class OpenWeatherException implements Exception {
  final String message;

  const OpenWeatherException(this.message);

  @override
  String toString() => 'OpenWeatherException: $message';
}

class OpenWeatherService {
  static const String _authority = 'api.openweathermap.org';
  static const String _path = '/data/2.5/weather';
  static const Duration _requestTimeout = Duration(seconds: 10);

  final http.Client _client;

  OpenWeatherService({http.Client? client}) : _client = client ?? http.Client();

  Future<WeatherData> getWeather({
    required double latitude,
    required double longitude,
  }) async {
    final uri = Uri.https(_authority, _path, {
      'lat': latitude.toStringAsFixed(6),
      'lon': longitude.toStringAsFixed(6),
      'units': 'metric',
      'appid': openWeatherApiKey,
      'lang': 'es',
    });

    http.Response response;
    try {
      response = await _client.get(uri).timeout(_requestTimeout);
    } on TimeoutException {
      throw const OpenWeatherException(
        'La solicitud excedió el tiempo de espera al consultar el clima.',
      );
    } on SocketException {
      throw const OpenWeatherException(
        'No hay conexión a internet disponible para consultar el clima.',
      );
    } catch (error) {
      throw OpenWeatherException(
        'Error inesperado al consultar el clima: $error',
      );
    }

    if (response.statusCode != 200) {
      throw OpenWeatherException(
        'El servicio respondió con un estado inesperado: ${response.statusCode}.',
      );
    }

    Map<String, dynamic> jsonBody;
    try {
      final decoded = json.decode(response.body);
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('El cuerpo de la respuesta no es un objeto JSON.');
      }
      jsonBody = decoded;
    } catch (error) {
      throw OpenWeatherException(
        'No se pudo interpretar la respuesta del servicio de clima: $error',
      );
    }

    final cod = jsonBody['cod'];
    final isSuccess = (cod is int && cod == 200) || (cod is String && cod == '200');
    if (!isSuccess) {
      final message = jsonBody['message'] ?? 'Error desconocido del servicio de clima.';
      throw OpenWeatherException('El servicio de clima reportó un error: $message');
    }

    return WeatherData.fromJson(jsonBody);
  }

  void dispose() {
    _client.close();
  }
}
