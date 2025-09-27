import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart' as permission_handler;

import '../models/weather_data.dart';
import '../services/weather_service.dart';
import '../widgets/wind_card.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final OpenWeatherService _weatherService = OpenWeatherService();

  WeatherData? _currentWeather;
  Position? _currentPosition;

  bool _isLoading = false;
  bool _serviceDisabled = false;
  bool _permissionDenied = false;
  bool _permissionDeniedForever = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadCurrentWeather();
  }

  @override
  void dispose() {
    _weatherService.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentWeather() async {
    setState(() {
      _isLoading = true;
      _serviceDisabled = false;
      _permissionDenied = false;
      _permissionDeniedForever = false;
      _errorMessage = null;
    });

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (!mounted) return;
        setState(() {
          _serviceDisabled = true;
          _isLoading = false;
          _currentWeather = null;
          _currentPosition = null;
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        if (!mounted) return;
        setState(() {
          _permissionDeniedForever = true;
          _isLoading = false;
          _currentWeather = null;
          _currentPosition = null;
        });
        return;
      }

      if (permission == LocationPermission.denied) {
        if (!mounted) return;
        setState(() {
          _permissionDenied = true;
          _isLoading = false;
          _currentWeather = null;
          _currentPosition = null;
        });
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final weather = await _weatherService.getWeather(
        latitude: position.latitude,
        longitude: position.longitude,
      );

      if (!mounted) return;
      setState(() {
        _currentWeather = weather;
        _currentPosition = position;
        _isLoading = false;
      });
    } on OpenWeatherException catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = error.message;
        _isLoading = false;
        _currentWeather = null;
        _currentPosition = null;
      });
    } on PlatformException catch (error) {
      if (!mounted) return;
      setState(() {
        final buffer = StringBuffer(
          'No se pudo acceder a la ubicación del dispositivo en este momento.',
        );

        if (kIsWeb) {
          buffer.write(
            ' En la versión web, verifica que el navegador tenga permisos de ubicación activos o consulta manualmente tu ciudad desde el servicio meteorológico.',
          );
        } else if (!kIsWeb &&
            (defaultTargetPlatform == TargetPlatform.macOS ||
                defaultTargetPlatform == TargetPlatform.windows ||
                defaultTargetPlatform == TargetPlatform.linux)) {
          buffer.write(
            ' En escritorio, asegúrate de habilitar el servicio de localización del sistema o consulta temporalmente el clima de tu ciudad de forma manual.',
          );
        }

        if (error.message != null && error.message!.isNotEmpty) {
          buffer.write(' Detalle técnico: ${error.message}.');
        }

        _errorMessage = buffer.toString();
        _isLoading = false;
        _currentWeather = null;
        _currentPosition = null;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage =
            'Ocurrió un error inesperado al obtener el clima: $error';
        _isLoading = false;
        _currentWeather = null;
        _currentPosition = null;
      });
    }
  }

  Widget _buildStatusMessage({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String message,
    List<Widget>? actions,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 12),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: iconColor),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
            if (actions != null && actions.isNotEmpty) ...[
              const SizedBox(height: 20),
              Wrap(
                spacing: 12,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: actions,
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Clima actual en tu ubicación'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualizar',
            onPressed: _isLoading ? null : _loadCurrentWeather,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadCurrentWeather,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Consulta la información meteorológica en tiempo real usando tus coordenadas actuales.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            if (_isLoading)
              const SizedBox(
                height: 280,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Buscando tu ubicación y clima actual...'),
                    ],
                  ),
                ),
              )
            else if (_serviceDisabled)
              _buildStatusMessage(
                icon: Icons.location_disabled,
                iconColor: Colors.redAccent,
                title: 'Servicio de ubicación desactivado',
                message:
                    'Activa los servicios de ubicación del dispositivo para obtener el clima en tiempo real.',
                actions: [
                  ElevatedButton.icon(
                    onPressed: Geolocator.openLocationSettings,
                    icon: const Icon(Icons.settings),
                    label: const Text('Abrir ajustes de ubicación'),
                  ),
                ],
              )
            else if (_permissionDeniedForever)
              _buildStatusMessage(
                icon: Icons.lock_outline,
                iconColor: Colors.deepOrange,
                title: 'Permiso de ubicación denegado permanentemente',
                message:
                    'Otorga permisos de ubicación desde la configuración del sistema para continuar.',
                actions: [
                  ElevatedButton.icon(
                    onPressed: permission_handler.openAppSettings,
                    icon: const Icon(Icons.settings),
                    label: const Text('Abrir configuración'),
                  ),
                ],
              )
            else if (_permissionDenied)
              _buildStatusMessage(
                icon: Icons.location_off,
                iconColor: Colors.orangeAccent,
                title: 'Permiso de ubicación denegado',
                message:
                    'Se necesita tu autorización para acceder a la ubicación y mostrar el clima. Inténtalo nuevamente.',
              )
            else if (_errorMessage != null)
              _buildStatusMessage(
                icon: Icons.error_outline,
                iconColor: Colors.red,
                title: 'No se pudo obtener el clima',
                message: _errorMessage!,
                actions: [
                  ElevatedButton.icon(
                    onPressed: _loadCurrentWeather,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reintentar'),
                  ),
                ],
              )
            else if (_currentWeather != null)
              WindCard(
                weatherData: _currentWeather!,
                latitude: _currentPosition?.latitude ?? _currentWeather!.latitude,
                longitude: _currentPosition?.longitude ?? _currentWeather!.longitude,
              )
            else
              _buildStatusMessage(
                icon: Icons.cloud,
                iconColor: Colors.blueGrey,
                title: 'Sin datos disponibles',
                message:
                    'Desliza hacia abajo para intentar obtener nuevamente la información meteorológica.',
              ),
            const SizedBox(height: 24),
            const Text(
              'Desliza hacia abajo para actualizar en cualquier momento.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
