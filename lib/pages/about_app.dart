import 'package:flutter/material.dart';

class AboutApp extends StatelessWidget {
  const AboutApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).secondaryHeaderColor,
      appBar: AppBar(
        title: const Text('About'),
      ),
      body: const Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              'About Easy Pos',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
                ' Welcom to Easy Pos, your reliable Point-of-sale solution for small buisness! Our goal is to simplity your daily operation and enhance your customer experience'),
            SizedBox(height: 20),
            Text(
              'Key Features',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
                ' - Process sales quickly with our user-friendly interface.\n - Organize your products with detailed descriptions, prices, and categories. \n - Keep an eye on inventory levels \n - Maintain a database of loyal customers \n - Access EasyPOS from anywhere using our mobile app or web portal.')
          ],
        ),
      ),
    );
  }
}
