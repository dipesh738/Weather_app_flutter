import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:weather_app/weather_screen.dart';

class WeatherNepal extends StatefulWidget {
  const WeatherNepal({super.key});

  @override
  State<WeatherNepal> createState() => _WeatherNepalState();
}

class _WeatherNepalState extends State<WeatherNepal> {
  late Future<List<String>> citiesFuture;
  String? selectedCity;
  Future<List<String>> fetchNepalCities() async {
    final res = await http.get(
      Uri.parse(
        'http://api.geonames.org/searchJSON?country=NP&featureClass=P&minPopulation=50000&orderby=population&maxRows=50&username=dipesh738',
      ),
    );
    if (res.statusCode != 200) {
      throw Exception('failed to load the cities');
    }
    final data = jsonDecode(res.body);
    final List cities = data['geonames'];
    return cities.map<String>((city) => city['name'].toString()).toList();
  }

  @override
  void initState() {
    super.initState();
    citiesFuture = fetchNepalCities();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Weather Nepal",
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          citiesFuture = fetchNepalCities();
          setState(() {});
          await citiesFuture;
        },
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(16.0),

          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              FutureBuilder<List<String>>(
                future: citiesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator.adaptive());
                  }
                  if (snapshot.hasError) {
                    return Text('Error :${snapshot.error}');
                  }
                  final cities = snapshot.data!;
                  return DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      label: Text("Select City"),
                      border: OutlineInputBorder(),
                    ),
                    initialValue: selectedCity,
                    items: cities.map((city) {
                      return DropdownMenuItem(value: city, child: Text(city));
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedCity = value;
                      });
                    },
                  );
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: selectedCity == null
                    ? null
                    : () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                WeatherScreen(cityName: selectedCity!),
                          ),
                        );
                      },
                child: Text("View Weather"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
