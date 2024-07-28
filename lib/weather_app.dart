import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:weather_app/additional_info.dart';
import 'package:weather_app/hourly_forcast.dart';
import 'package:weather_app/secrets.dart';

class WeatherApp extends StatefulWidget {
  const WeatherApp({super.key});

  @override
  State<WeatherApp> createState() => _WeatherAppState();
}

class _WeatherAppState extends State<WeatherApp> {
  String dropdownValue = 'Mumbai'; // Declare dropdownValue here
  double? currTemp;
  double? currHumidity;
  double? pressure;
  double? windSpeed;
  String? currCondition;

  Map<String, dynamic> forecast = {"time":<String>[], "clouds":<String>[], "temp":<double>[]};

  Future<void> getCurrentWeather() async {
    final res = await http.get(Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather?q=$dropdownValue&APPID=$apiKey'));
    final data = jsonDecode(res.body);
    setState(() {
      currTemp = (data['main']['temp'] as num).toDouble() - 273.15;
      currHumidity = (data['main']['humidity'] as num).toDouble();
      windSpeed = (data['wind']['speed'] as num).toDouble();
      pressure = (data['main']['pressure'] as num).toDouble();
      currCondition = (data['weather'][0]['main']);
    });
  }

  Future<void> getForecast() async {
    final res = await http.get(Uri.parse(
        'https://api.openweathermap.org/data/2.5/forecast?q=$dropdownValue&APPID=$apiKey'));
    final data = jsonDecode(res.body);
    final arr = data["list"];
    
    setState(() {
      forecast.clear();
      forecast = {"time": <String>[], "clouds": <String>[], "temp": <double>[]};
      for (var i = 0; i < arr.length; i++) {
        forecast['time'].add((arr[i]["dt_txt"] as String).substring(11, 16));
        forecast['temp'].add((arr[i]["main"]["temp"] as num).toDouble() - 273.15);
        forecast['clouds'].add(arr[i]["weather"][0]["main"] as String);
      }
    });
  }
  

  Future<void> fetchWeatherData() async {
    await Future.wait([getCurrentWeather(), getForecast()]);
  }

  @override
  void initState() {
    super.initState();
    fetchWeatherData();
  }

  IconData _getWeatherIcon(String weather) {
    switch (weather.toLowerCase()) {
      case 'rain':
        return Icons.thunderstorm;
      case 'clouds':
        return Icons.cloud;
      case 'snow':
        return Icons.ac_unit;
      case 'thunderstorm':
        return Icons.flash_on;
      default:
        return Icons.wb_cloudy;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Mausam',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              fetchWeatherData(); // Call fetchWeatherData directly
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // main card
            SizedBox(
              width: double.infinity,
              child: Card(
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(30))),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Padding(
                      padding: const EdgeInsets.all(30),
                      child: Column(
                        children: [
                          Text(dropdownValue, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),),
                          DropdownButton<String>(
                            value: dropdownValue,
                            icon: const Icon(Icons.menu),
                            style: const TextStyle(color: Colors.white, fontSize: 14),
                            underline: Container(
                              height: 2,
                              color: Colors.black,
                            ),
                            onChanged: (String? newValue) {
                              setState(() {
                                dropdownValue = newValue!;
                                fetchWeatherData();
                              });
                            },
                            items: <String>['Mumbai', 'Delhi', 'Bangalore', 'Chennai', 'Kolkata','Indore', 'Hyderabad', 'Pune']
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                          ),
                          Text(
                            currTemp != null ? '${currTemp?.toStringAsFixed(2)} °C' : 'Loading...',
                            style: const TextStyle(
                                fontSize: 32, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Icon(
                            _getWeatherIcon(currCondition ?? 'N/A'),
                            size: 46,
                          ),
                          Text(
                            currCondition ?? "Loading....",
                            style: const TextStyle(fontSize: 32),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            const Text(
              'Weather Forecast',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 160,
              child: Container(
                margin: const EdgeInsets.only(left: 10, right: 10),
                padding: const EdgeInsets.only(top: 10, bottom: 20),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: forecast["time"]?.length,
                  itemBuilder: (context, index) {
                    return HourlyForcast(
                      time: forecast['time']?[index] ?? 'N/A',
                      icon: _getWeatherIcon(forecast['clouds']?[index] ?? 'N/A'),
                      temp: (forecast['temp'][index] ?? 0.0).toStringAsFixed(2),
                    );
                  },
                ),
              ),
            ),
            const Text(
              'Additional Information',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Container(
              margin: const EdgeInsets.only(top: 20, left: 10, right: 10),
              child: Card(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    AdditionalInfo(
                      icon: Icons.water_drop,
                      label: 'Humidity',
                      value: currHumidity != null ? '$currHumidity%' : 'Loading...'),
                    AdditionalInfo(
                      icon: Icons.air,
                      label: 'Wind Speed',
                      value: windSpeed != null ? '$windSpeed m/s' : 'Loading...'),
                    AdditionalInfo(
                      icon: Icons.beach_access,
                      label: 'Pressure',
                      value: pressure != null ? '$pressure hPa' : 'Loading...'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
