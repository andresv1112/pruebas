import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/weather_data.dart';

class WeatherCard extends StatelessWidget {
  WeatherCard({super.key, required this.weatherData})
      : _dateFormat = DateFormat('dd/MM/yyyy HH:mm');

  final WeatherData weatherData;

  final DateFormat _dateFormat;

  String? _formatTemperature(double? value) {
    if (value == null) return null;
    return '${value.toStringAsFixed(1)}°C';
  }

  String? _formatSpeed(double? value) {
    if (value == null) return null;
    return '${value.toStringAsFixed(1)} m/s';
  }

  String? _formatVisibility(double? value) {
    if (value == null) return null;
    return '${value.toStringAsFixed(1)} km';
  }

  String? _formatPressure(int? value) {
    if (value == null) return null;
    return '$value hPa';
  }

  String? _formatHumidity(int? value) {
    if (value == null) return null;
    return '$value%';
  }

  String? _formatClouds(int? value) {
    if (value == null) return null;
    return '$value%';
  }

  String? _formatTime(DateTime? value) {
    if (value == null) return null;
    return _dateFormat.format(value);
  }

  String? _capitalize(String? value) {
    if (value == null || value.isEmpty) return null;
    if (value.length == 1) return value.toUpperCase();
    return value[0].toUpperCase() + value.substring(1);
  }

  String? _windDirection(int? degree) {
    if (degree == null) return null;
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

  Widget _buildMetric({
    required IconData icon,
    required String label,
    required String value,
    Color? color,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: color ?? Colors.blueGrey, size: 22),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color ?? Colors.blueGrey[800],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final temperature = _formatTemperature(weatherData.temperature);
    final feelsLike = _formatTemperature(weatherData.feelsLike);
    final minTemp = _formatTemperature(weatherData.tempMin);
    final maxTemp = _formatTemperature(weatherData.tempMax);
    final humidity = _formatHumidity(weatherData.humidity);
    final pressure = _formatPressure(weatherData.pressure);
    final visibility = _formatVisibility(weatherData.visibilityKm);
    final clouds = _formatClouds(weatherData.cloudiness);
    final windSpeed = _formatSpeed(weatherData.windSpeed);
    final windGust = _formatSpeed(weatherData.windGust);
    final windDirection = _windDirection(weatherData.windDegree);
    final observationTime = _formatTime(weatherData.observationTime);
    final sunrise = _formatTime(weatherData.sunrise);
    final sunset = _formatTime(weatherData.sunset);
    final description = _capitalize(weatherData.description);
    final temperatureRangeParts = <String>[];
    if (minTemp != null) {
      temperatureRangeParts.add('Mín: $minTemp');
    }
    if (maxTemp != null) {
      temperatureRangeParts.add('Máx: $maxTemp');
    }
    final temperatureRange = temperatureRangeParts.join('  ·  ');

    final sunScheduleParts = <String>[];
    if (sunrise != null) {
      sunScheduleParts.add('Amanecer: $sunrise');
    }
    if (sunset != null) {
      sunScheduleParts.add('Atardecer: $sunset');
    }
    final sunSchedule = sunScheduleParts.join('  ·  ');

    final metricWidgets = <Widget>[];
    if (humidity != null) {
      metricWidgets.add(
        Expanded(
          child: _buildMetric(
            icon: Icons.water_drop,
            label: 'Humedad',
            value: humidity,
            color: Colors.cyan[600],
          ),
        ),
      );
    }
    if (pressure != null) {
      metricWidgets.add(
        Expanded(
          child: _buildMetric(
            icon: Icons.speed,
            label: 'Presión',
            value: pressure,
            color: Colors.purple[400],
          ),
        ),
      );
    }
    if (clouds != null) {
      metricWidgets.add(
        Expanded(
          child: _buildMetric(
            icon: Icons.cloud,
            label: 'Nubosidad',
            value: clouds,
            color: Colors.blueGrey[400],
          ),
        ),
      );
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.location_on,
                  color: Colors.blue,
                  size: 22,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    weatherData.countryCode != null
                        ? '${weatherData.cityName}, ${weatherData.countryCode}'
                        : weatherData.cityName,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[800],
                    ),
                  ),
                ),
              ],
            ),
            if (description != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (temperature != null)
                  Text(
                    temperature,
                    style: theme.textTheme.displaySmall?.copyWith(
                      color: Colors.orange[600],
                      fontWeight: FontWeight.bold,
                    ),
                  )
                else
                  Text(
                    '--°C',
                    style: theme.textTheme.displaySmall?.copyWith(
                      color: Colors.orange[300],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (feelsLike != null)
                        Text(
                          'Sensación térmica: $feelsLike',
                          style: TextStyle(
                            color: Colors.grey[700],
                          ),
                        ),
                      if (temperatureRange.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            temperatureRange,
                            style: TextStyle(
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (metricWidgets.isNotEmpty) ...[
              Row(
                children: [
                  for (int i = 0; i < metricWidgets.length; i++) ...[
                    if (i > 0) const SizedBox(width: 12),
                    metricWidgets[i],
                  ],
                ],
              ),
            ],
            if (visibility != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.remove_red_eye, size: 20, color: Colors.green[600]),
                  const SizedBox(width: 6),
                  Text(
                    'Visibilidad: $visibility',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ],
              ),
            ],
            if (windSpeed != null || windDirection != null || windGust != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.air, color: Colors.blue, size: 26),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Viento',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (windSpeed != null)
                            Text(
                              'Velocidad: $windSpeed',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          if (windDirection != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text('Dirección: $windDirection'),
                            ),
                          if (windGust != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text('Ráfagas: $windGust'),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (observationTime != null || sunrise != null || sunset != null) ...[
              const SizedBox(height: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (observationTime != null)
                    Row(
                      children: [
                        Icon(Icons.access_time, size: 18, color: Colors.grey[600]),
                        const SizedBox(width: 6),
                        Text(
                          'Actualizado: $observationTime',
                          style: TextStyle(color: Colors.grey[700], fontSize: 12),
                        ),
                      ],
                    ),
                  if (sunSchedule.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Row(
                        children: [
                          Icon(Icons.wb_sunny, size: 18, color: Colors.amber[600]),
                          const SizedBox(width: 6),
                          Text(
                            sunSchedule,
                            style: TextStyle(color: Colors.grey[700], fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ],
            if (weatherData.latitude != null && weatherData.longitude != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.public, size: 18, color: Colors.grey[600]),
                  const SizedBox(width: 6),
                  Text(
                    'Lat: ${weatherData.latitude!.toStringAsFixed(2)} · Lon: ${weatherData.longitude!.toStringAsFixed(2)}',
                    style: TextStyle(color: Colors.grey[700], fontSize: 12),
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
