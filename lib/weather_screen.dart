import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weather_app/additional_info_item.dart';
import 'package:weather_app/api_keys.dart';
import 'package:weather_app/hourly_weather_forecast.dart';
import 'package:http/http.dart' as http;

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  late Future<Map<String, dynamic>> weather;

  Future<Map<String, dynamic>> getCurrentWeather() async {
    try {
      String placeName = "Kathmandu";

      final res = await http.get(
        Uri.parse(
          'https://api.openweathermap.org/data/2.5/forecast?q=$placeName&APPID=$openWeatherApiKey',
        ),
      );
      final data = jsonDecode(res.body);
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Weather App",
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                weather = getCurrentWeather();
              });
            },
            icon: Icon(Icons.refresh),
          ),
        ],
      ),
      body: FutureBuilder(
        future: weather,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator.adaptive());
          }
          if (snapshot.hasError) {
            Center(child: Text(snapshot.hasError.toString()));
          }
          final data = snapshot.data!;
          final currentWeatherdata = data['list'][0];
          final currentWeather = currentWeatherdata['main']['temp'];
          final currentSky = currentWeatherdata['weather'][0]['main'];
          final currentpressure = currentWeatherdata['main']['pressure'];
          final currenthumidity = currentWeatherdata['main']['humidity'];
          final currentAirSpeed = currentWeatherdata['wind']['speed'];

          return Padding(
            padding: const EdgeInsets.all(16.0),
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
                                '$currentWeather K',
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

                              Text(currentSky, style: TextStyle(fontSize: 20)),
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
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 5,
                    itemBuilder: (context, index) {
                      final hourlyForecast = data['list'][index + 1];
                      final hourlyIcon = hourlyForecast['weather'][0]['Clouds'];
                      final hourlyTemp = hourlyForecast['main']['temp'];
                      final time = DateTime.parse(hourlyForecast['dt_txt']);

                      return HourlyWeatherForecast(
                        icon: hourlyIcon == 'Clouds' || hourlyIcon == 'Rain'
                            ? Icons.cloud
                            : Icons.sunny,
                        temp: hourlyTemp.toString(),
                        time: DateFormat.Hm().format(time),
                      );
                    },
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
          );
        },
      ),
    );
  }
}
