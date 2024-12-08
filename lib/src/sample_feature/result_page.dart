import 'package:flutter/material.dart';
import 'dart:io';

class ResultPage extends StatelessWidget {
  final File imageFile;
  final String name;
  final String aadhaarNumber;

  const ResultPage({
    Key? key,
    required this.imageFile,
    required this.name,
    required this.aadhaarNumber,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Aadhaar Details"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Extracted Aadhaar Details:",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Image.file(imageFile, height: 200),
            const SizedBox(height: 20),
            Text(
              "Name: $name",
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 10),
            Text(
              "Aadhaar Number: $aadhaarNumber",
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
