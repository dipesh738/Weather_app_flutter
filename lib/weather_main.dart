import 'package:flutter/material.dart';
import 'package:weather_app/weather_home_screen.dart';
import 'package:weather_app/weather_nepal.dart';

class WeatherMain extends StatefulWidget {
  const WeatherMain({super.key});

  @override
  State<WeatherMain> createState() => _WeatherMainState();
}

class _WeatherMainState extends State<WeatherMain> {
  int _selectedindex = 0;
  final List<Widget> widgetOption = const [WeatherHomeScreen(), WeatherNepal()];
  void _onItemTapped(int index) {
    setState(() {
      _selectedindex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widgetOption.elementAt(_selectedindex),
      bottomNavigationBar: BottomNavigationBar(
        showSelectedLabels: true,

        showUnselectedLabels: true,
        selectedItemColor: Colors.amber,
        unselectedItemColor: Colors.blueGrey,
        type: BottomNavigationBarType.fixed,

        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.air), label: "Weathers"),
        ],
        currentIndex: _selectedindex,
        onTap: _onItemTapped,
      ),
    );
  }
}
