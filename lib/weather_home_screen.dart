import 'dart:convert';
import 'dart:ui';
import 'package:geolocator/geolocator.dart';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weather_app/weatherinfo/additional_info_item.dart';
import 'package:weather_app/weatherinfo/api_keys.dart';
import 'package:weather_app/weatherinfo/hourly_weather_forecast.dart';
import 'package:http/http.dart' as http;
import 'package:weather_app/weatherinfo/scroll_arrow.dart';

class WeatherHomeScreen extends StatefulWidget {
  const WeatherHomeScreen({super.key});

  @override
  State<WeatherHomeScreen> createState() => _WeatherHomeScreenState();
}

class _WeatherHomeScreenState extends State<WeatherHomeScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _showLeftArrow = false;
  bool _showRightArrow = true;

  late Future<Map<String, dynamic>> weather;

  Future<Position> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception("Location Services are disabled");
    }
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception("Location Permission permanently denied");
    }
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  Future<Map<String, dynamic>> getCurrentWeather() async {
    try {
      final position = await _getCurrentLocation();
      final res = await http.get(
        Uri.parse(
          'https://api.openweathermap.org/data/2.5/forecast'
          '?lat=${position.latitude}'
          '&lon=${position.longitude}'
          '&units=metric'
          '&appid=$openWeatherApiKey',
        ),
      );
      final data = jsonDecode(res.body);
      setState(() {});

      if (data['cod'] != '200') {
        throw 'message ';
      }
      return data;
    } catch (e) {
      throw e.toString();
    }
  }

  @override
  void initState() {
    super.initState();
    weather = getCurrentWeather();

    _scrollController.addListener(() {
      final position = _scrollController.position;
      final threshold = 5.0;
      setState(() {
        _showLeftArrow = position.pixels > threshold;
        _showRightArrow =
            position.pixels < position.maxScrollExtent - threshold;
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Weather Today',
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder(
        future: weather,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator.adaptive());
          }
          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }
          final data = snapshot.data!;
          final currentWeatherdata = data['list'][0];
          final currentWeather = currentWeatherdata['main']['temp'];
          final currentSky = currentWeatherdata['weather'][0]['main'];
          final currentpressure = currentWeatherdata['main']['pressure'];
          final currenthumidity = currentWeatherdata['main']['humidity'];
          final currentAirSpeed = currentWeatherdata['wind']['speed'];
          final DateTime now = DateTime.now();

          final List upcomingForecasts = data['list'].where((forecast) {
            final forecastTime = DateTime.parse(forecast['dt_txt']);
            return forecastTime.isAfter(now);
          }).toList();

          final hourlyData = upcomingForecasts.take(5).toList();

          return RefreshIndicator(
            onRefresh: () async {
              weather = getCurrentWeather();
              setState(() {});
              await weather;
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // main part
                  SizedBox(
                    width: double.infinity,
                    child: Card(
                      elevation: 10,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),

                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                Text(
                                  '$currentWeather °C',
                                  style: const TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Icon(
                                  currentSky == 'Clouds' || currentSky == 'Rain'
                                      ? Icons.cloud
                                      : Icons.sunny,
                                  size: 64,
                                ),
                                const SizedBox(height: 16),

                                Text(
                                  currentSky,
                                  style: TextStyle(fontSize: 20),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),

                  // WEATHER FORECASR
                  Text(
                    "Weather Forecast",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),

                  SizedBox(height: 8),

                  // HOURLY WEARHER FORCAST
                  SizedBox(
                    height: 120,
                    child: Stack(
                      children: [
                        ListView.builder(
                          controller: _scrollController,
                          scrollDirection: Axis.horizontal,
                          itemCount: hourlyData.length,
                          itemBuilder: (context, index) {
                            final hourlyForecast = hourlyData[index];
                            final hourlyIcon =
                                hourlyForecast['weather'][0]['main'];
                            final hourlyTemp = hourlyForecast['main']['temp'];
                            final time = DateTime.parse(
                              hourlyForecast['dt_txt'],
                            );

                            return HourlyWeatherForecast(
                              icon:
                                  hourlyIcon == 'Clouds' || hourlyIcon == 'Rain'
                                  ? Icons.cloud
                                  : Icons.sunny,
                              temp: hourlyTemp.toString(),
                              time: DateFormat.Hm().format(time),
                            );
                          },
                        ),
                        if (_showLeftArrow)
                          Positioned(
                            top: 40,
                            left: 0,
                            child: ScrollArrow(
                              icon: Icons.arrow_back_ios_new,
                              onTap: () {
                                _scrollController.animateTo(
                                  _scrollController.offset - 120,
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeOut,
                                );
                              },
                            ),
                          ),

                        if (_showRightArrow)
                          Positioned(
                            top: 40,
                            right: 0,
                            child: ScrollArrow(
                              icon: Icons.arrow_forward_ios,
                              onTap: () {
                                _scrollController.animateTo(
                                  _scrollController.offset + 120,
                                  duration: Duration(milliseconds: 300),
                                  curve: Curves.easeOut,
                                );
                              },
                            ),
                          ),
                      ],
                    ),
                  ),

                  SizedBox(height: 20),

                  // ADDITIONAL INFORMATION
                  Text(
                    "Additional Information",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),

                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        AdditionalInfoItem(
                          icon: Icons.water_drop,
                          label: "Humidity",
                          value: currenthumidity.toString(),
                        ),
                        AdditionalInfoItem(
                          icon: Icons.air,
                          label: "air speed",
                          value: currentAirSpeed.toString(),
                        ),
                        AdditionalInfoItem(
                          icon: Icons.beach_access,
                          label: "pressure",
                          value: currentpressure.toString(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
