import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/wind_data.dart';

class WindCard extends StatelessWidget {
  final WindData windData;

  const WindCard({super.key, required this.windData});

  @override
  Widget build(BuildContext context) {
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
            // Header con estación
            Row(
              children: [
                const Icon(
                  Icons.location_on,
                  color: Colors.blue,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    windData.estacion ?? 'Estación desconocida',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            if (windData.codigo != null) ...[
              Text(
                'Código estación: ${windData.codigo}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
            ],

            // Ubicación
            Text(
              '${windData.municipio ?? 'N/A'}, ${windData.departamento ?? 'N/A'}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 12),
            
            // Información del viento
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.air,
                    color: Colors.blue,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Velocidad del Viento',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          windData.velocidadViento != null 
                              ? '${windData.velocidadViento!.toStringAsFixed(1)} m/s'
                              : 'N/A',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (windData.direccionViento != null) ...[
                    const SizedBox(width: 12),
                    Column(
                      children: [
                        const Icon(
                          Icons.navigation,
                          color: Colors.blue,
                          size: 20,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          windData.direccionViento!,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),
            
            // Datos adicionales
            Row(
              children: [
                if (windData.temperatura != null)
                  Expanded(
                    child: _buildDataItem(
                      Icons.thermostat,
                      'Temperatura',
                      '${windData.temperatura!.toStringAsFixed(1)}°C',
                      Colors.orange,
                    ),
                  ),
                if (windData.humedad != null)
                  Expanded(
                    child: _buildDataItem(
                      Icons.water_drop,
                      'Humedad',
                      '${windData.humedad!.toStringAsFixed(0)}%',
                      Colors.cyan,
                    ),
                  ),
                if (windData.presion != null)
                  Expanded(
                    child: _buildDataItem(
                      Icons.speed,
                      'Presión',
                      '${windData.presion!.toStringAsFixed(1)} hPa',
                      Colors.purple,
                    ),
                  ),
              ],
            ),
            
            // Fecha de observación
            if (windData.fechaObservacion != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Última observación: ${DateFormat('dd/MM/yyyy HH:mm').format(windData.fechaObservacion!)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],

            if (windData.latitud != null && windData.longitud != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.public,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Lat: ${windData.latitud!.toStringAsFixed(2)}  ·  Lon: ${windData.longitud!.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
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

  Widget _buildDataItem(IconData icon, String label, String value, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
