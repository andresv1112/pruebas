import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/weather_data.dart';

class WindCard extends StatelessWidget {
  WindCard({
    super.key,
    required this.weatherData,
    this.latitude,
    this.longitude,
  }) : _dateFormat = DateFormat('dd/MM/yyyy HH:mm');

  final WeatherData weatherData;
  final double? latitude;
  final double? longitude;
  final DateFormat _dateFormat;

  String _formatTemperature(double? value) {
    if (value == null) return 'Sin datos';
    return '${value.toStringAsFixed(1)}°C';
  }

  String _formatWindSpeed(double? value) {
    if (value == null) return 'Sin datos';
    return '${value.toStringAsFixed(1)} m/s';
  }

  String _formatHumidity(int? value) {
    if (value == null) return 'Sin datos';
    return '$value%';
  }

  String _formatPressure(int? value) {
    if (value == null) return 'Sin datos';
    return '$value hPa';
  }

  String _formatDescription(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Sin descripción disponible';
    }
    final normalized = value.trim();
    return normalized[0].toUpperCase() + normalized.substring(1);
  }

  String _formatWindDirection(int? degree) {
    if (degree == null) return 'Sin datos';
    const directions = [
      'N',
      'NNE',
      'NE',
      'ENE',
      'E',
      'ESE',
      'SE',
      'SSE',
      'S',
      'SSO',
      'SO',
      'OSO',
      'O',
      'ONO',
      'NO',
      'NNO',
    ];
    final index = ((degree % 360) / 22.5).round() % directions.length;
    return '${directions[index]} ($degree°)';
  }

  String _formatCoordinate(double? value) {
    if (value == null) return '--';
    return value.toStringAsFixed(4);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cityName = weatherData.countryCode != null
        ? '${weatherData.cityName}, ${weatherData.countryCode}'
        : weatherData.cityName;
    final locationLatitude = latitude ?? weatherData.latitude;
    final locationLongitude = longitude ?? weatherData.longitude;
    final observationTime = weatherData.observationTime;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.location_on, color: Colors.blueAccent),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cityName,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Coordenadas: lat ${_formatCoordinate(locationLatitude)} · lon ${_formatCoordinate(locationLongitude)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _formatTemperature(weatherData.temperature),
                    style: theme.textTheme.displaySmall?.copyWith(
                      color: Colors.orange[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _formatDescription(weatherData.description),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Sensación térmica: ${_formatTemperature(weatherData.feelsLike)}',
                        style: theme.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.water_drop, size: 18, color: Colors.cyan),
                          const SizedBox(width: 6),
                          Text('Humedad: ${_formatHumidity(weatherData.humidity)}'),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.speed, size: 18, color: Colors.purple),
                          const SizedBox(width: 6),
                          Text('Presión: ${_formatPressure(weatherData.pressure)}'),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.air, color: Colors.blue),
                      const SizedBox(width: 8),
                      Text(
                        'Viento',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    runSpacing: 8,
                    spacing: 16,
                    children: [
                      _MetricChip(
                        icon: Icons.speed,
                        label: 'Velocidad',
                        value: _formatWindSpeed(weatherData.windSpeed),
                      ),
                      _MetricChip(
                        icon: Icons.explore,
                        label: 'Dirección',
                        value: _formatWindDirection(weatherData.windDegree),
                      ),
                      if (weatherData.windGust != null)
                        _MetricChip(
                          icon: Icons.assistant_photo,
                          label: 'Ráfaga',
                          value: _formatWindSpeed(weatherData.windGust),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            if (observationTime != null) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.access_time, size: 18, color: Colors.grey),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Actualizado: ${_dateFormat.format(observationTime)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  const _MetricChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: Colors.blueGrey),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
