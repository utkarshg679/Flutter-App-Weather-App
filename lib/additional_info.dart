import 'package:flutter/material.dart';

class AdditionalInfo extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
    const AdditionalInfo({super.key, required this.icon, required this.label, required this.value}); 
  @override
  Widget build(BuildContext context) {
    
    return Container(
            margin: const EdgeInsets.all(10),
            child: Column(
              children: [
                Icon(icon, size: 32,),
                Padding(
                  padding: const EdgeInsets.only(top: 10, bottom: 10),
                  child: Text(label,style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w400), ),
                ),
                Text(value,style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold), ),
              ],
            ),
            
          );
  }
}