class WeatherData {
  final String cityName;
  final String? countryCode;
  final String? description;
  final String? weatherIcon;
  final double? temperature;
  final double? feelsLike;
  final double? tempMin;
  final double? tempMax;
  final int? humidity;
  final int? pressure;
  final double? visibilityKm;
  final double? windSpeed;
  final int? windDegree;
  final double? windGust;
  final int? cloudiness;
  final double? latitude;
  final double? longitude;
  final DateTime? observationTime;
  final DateTime? sunrise;
  final DateTime? sunset;

  const WeatherData({
    required this.cityName,
    this.countryCode,
    this.description,
    this.weatherIcon,
    this.temperature,
    this.feelsLike,
    this.tempMin,
    this.tempMax,
    this.humidity,
    this.pressure,
    this.visibilityKm,
    this.windSpeed,
    this.windDegree,
    this.windGust,
    this.cloudiness,
    this.latitude,
    this.longitude,
    this.observationTime,
    this.sunrise,
    this.sunset,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    final coord = (json['coord'] as Map?)?.cast<String, dynamic>();
    final main = (json['main'] as Map?)?.cast<String, dynamic>();
    final weatherList = json['weather'] as List<dynamic>?;
    final wind = (json['wind'] as Map?)?.cast<String, dynamic>();
    final clouds = (json['clouds'] as Map?)?.cast<String, dynamic>();
    final sys = (json['sys'] as Map?)?.cast<String, dynamic>();

    Map<String, dynamic>? firstWeather;
    if (weatherList != null && weatherList.isNotEmpty) {
      final element = weatherList.first;
      if (element is Map) {
        firstWeather = element.cast<String, dynamic>();
      }
    }

    DateTime? _parseUnix(num? timestamp, {int? timezoneOffset}) {
      if (timestamp == null) return null;
      final milliseconds = (timestamp.toDouble() * 1000).toInt();
      final utcDate = DateTime.fromMillisecondsSinceEpoch(milliseconds, isUtc: true);
      final adjusted = timezoneOffset != null
          ? utcDate.add(Duration(seconds: timezoneOffset))
          : utcDate;
      return adjusted.toLocal();
    }

    final timezoneOffset = json['timezone'] is num ? (json['timezone'] as num).toInt() : null;
    final dt = json['dt'] is num ? (json['dt'] as num).toInt() : null;

    return WeatherData(
      cityName: (json['name'] as String?)?.trim().isNotEmpty == true
          ? (json['name'] as String).trim()
          : 'Ubicación desconocida',
      countryCode: (sys?['country'] as String?)?.trim(),
      description: firstWeather?['description'] as String?,
      weatherIcon: firstWeather?['icon'] as String?,
      temperature: (main?['temp'] as num?)?.toDouble(),
      feelsLike: (main?['feels_like'] as num?)?.toDouble(),
      tempMin: (main?['temp_min'] as num?)?.toDouble(),
      tempMax: (main?['temp_max'] as num?)?.toDouble(),
      humidity: (main?['humidity'] as num?)?.toInt(),
      pressure: (main?['pressure'] as num?)?.toInt(),
      visibilityKm: json['visibility'] is num
          ? (json['visibility'] as num).toDouble() / 1000
          : null,
      windSpeed: (wind?['speed'] as num?)?.toDouble(),
      windDegree: (wind?['deg'] as num?)?.toInt(),
      windGust: (wind?['gust'] as num?)?.toDouble(),
      cloudiness: (clouds?['all'] as num?)?.toInt(),
      latitude: (coord?['lat'] as num?)?.toDouble(),
      longitude: (coord?['lon'] as num?)?.toDouble(),
      observationTime: _parseUnix(dt, timezoneOffset: timezoneOffset),
      sunrise: _parseUnix(sys?['sunrise'] as num?, timezoneOffset: timezoneOffset),
      sunset: _parseUnix(sys?['sunset'] as num?, timezoneOffset: timezoneOffset),
    );
  }

  WeatherData copyWith({
    String? cityName,
  }) {
    return WeatherData(
      cityName: cityName ?? this.cityName,
      countryCode: countryCode,
      description: description,
      weatherIcon: weatherIcon,
      temperature: temperature,
      feelsLike: feelsLike,
      tempMin: tempMin,
      tempMax: tempMax,
      humidity: humidity,
      pressure: pressure,
      visibilityKm: visibilityKm,
      windSpeed: windSpeed,
      windDegree: windDegree,
      windGust: windGust,
      cloudiness: cloudiness,
      latitude: latitude,
      longitude: longitude,
      observationTime: observationTime,
      sunrise: sunrise,
      sunset: sunset,
    );
  }
}
