import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:weather_app/additional_info_item.dart';
import 'package:weather_app/hourly_weather_forecast.dart';

class WeatherScreen extends StatelessWidget {
  const WeatherScreen({super.key});

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
              print("refreshed");
            },
            icon: Icon(Icons.refresh),
          ),
        ],
      ),
      body: Padding(
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
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Text(
                            "300K",
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Icon(Icons.cloud, size: 64),
                          const SizedBox(height: 16),

                          Text("Rain", style: TextStyle(fontSize: 20)),
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
            const SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  HourlyWeatherForecast(
                    time: "03:00",
                    icon: Icons.storm,
                    temp: "202.34",
                  ),
                  HourlyWeatherForecast(
                    time: "04:00",
                    icon: Icons.water,
                    temp: "402.34",
                  ),
                  HourlyWeatherForecast(
                    time: "04:00",
                    icon: Icons.wind_power,
                    temp: "502.34",
                  ),
                  HourlyWeatherForecast(
                    time: "06:00",
                    icon: Icons.sunny,
                    temp: "902.34",
                  ),
                  HourlyWeatherForecast(
                    time: "08:00",
                    icon: Icons.cloud,
                    temp: "102.34",
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
                    value: "200",
                  ),
                  AdditionalInfoItem(
                    icon: Icons.air,
                    label: "air speed",
                    value: "7.6",
                  ),
                  AdditionalInfoItem(
                    icon: Icons.beach_access,
                    label: "pressure",
                    value: "1006",
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
