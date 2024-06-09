import 'package:flutter/material.dart';
class HourlyForcast extends StatelessWidget {
  final String time;
  final IconData icon;
  final String temp;
  const HourlyForcast({super.key, required this.time, required this.icon, required this.temp});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      height: 140,
      child: Card(
        child: Container(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
          padding: const EdgeInsets.all(15.0),
          child: Column(
            children: [
              Text(
                time,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Icon(
                icon,
                size: 36,
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                '$temp °C',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              )
            ],
          ),
        ),
      ),
    );
  }
}
