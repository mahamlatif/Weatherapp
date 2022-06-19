import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('pl.jpg'),
              fit: BoxFit.cover,
            ),
          ),
          child: WeatherAppHomePage(),
        ),
      ),
    ),
  );
}

class WeatherAppHomePage extends StatefulWidget {
  WeatherAppHomePage({Key? key}) : super(key: key);

  @override
  State<WeatherAppHomePage> createState() => _WeatherAppHomePageState();
}

class _WeatherAppHomePageState extends State<WeatherAppHomePage> {
  double longitude = 0.0;
  double latitude = 0.0;
  double temperatue = 0.0;
  String? city;
  String? country;
  @override
  void initState() {
    FetchLocation();

    super.initState();
  }

  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              children: [
                Text(
                  city.toString(),
                  style: TextStyle(
                      fontSize: 40,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                ),
                Text(
                  country.toString(),
                  style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                ),
              ],
            )
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              temperatue.toStringAsFixed(1) + "°C",
              style: TextStyle(
                  fontSize: 60,
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ],
    );
  }

  void FetchLocation() async {
    bool permission = false;
    LocationPermission checkpermission = await Geolocator.checkPermission();
    if (checkpermission == LocationPermission.denied ||
        checkpermission == LocationPermission.deniedForever) {
      LocationPermission reqpermission = await Geolocator.requestPermission();
      print(reqpermission);
      if (reqpermission == LocationPermission.whileInUse ||
          reqpermission == LocationPermission.always) {
        permission = true;
      }
    } else {
      permission = true;
    }
    if (permission) {
      Position location = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best);
      longitude = location.longitude;
      latitude = location.latitude;
      print(location);
      FetchWeather();
    } else {
      print('Location permision denied.');
    }
  }

  void FetchWeather() async {
    const String Api_Key = "7c7731ecdaf211034311405e3708bd5d";
    String urlString =
        "https://api.openweathermap.org/data/2.5/weather?lat=$latitude&lon=$longitude&appid=$Api_Key";
    var url = Uri.parse(urlString);
    http.Response response = await http.get(url);
    print(response.body);
    var responseBody = response.body;
    var parsedResponse = json.decode(responseBody);
    print(parsedResponse['main']['temp']);
    print(parsedResponse['name']);
    print(parsedResponse['sys']['country']);
    setState(() {
      temperatue = parsedResponse['main']['temp'] - 273.15;
      city = parsedResponse['name'];
      country = parsedResponse['sys']['country'];
    });
  }
}
