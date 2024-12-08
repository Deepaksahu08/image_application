// ignore_for_file: library_private_types_in_public_api, depend_on_referenced_packages, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'result_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  String _name = "Not detected";
  String _aadhaarNumber = "Not detected";

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
      await _processImage(_selectedImage!);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No image selected!")),
      );
    }
  }

  Future<void> _processImage(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);
    final textRecognizer = TextRecognizer();

    try {
      final RecognizedText recognizedText =
          await textRecognizer.processImage(inputImage);

      _extractAadhaarDetails(recognizedText.text);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  void _extractAadhaarDetails(String text) {
    final lines = text.split('\n');

    String extractedName = "Not detected";
    String extractedAadhaarNumber = "Not detected";

    // Extract Name after "GOVERNMENT OF INDIA"
    final indiaIndex = lines.indexWhere(
        (line) => line.toUpperCase().contains("GOVERNMENT OF INDIA"));

    if (indiaIndex != -1) {
      // Find first non-empty line after "GOVERNMENT OF INDIA"
      for (int i = indiaIndex + 1; i < lines.length; i++) {
        if (lines[i].trim().isNotEmpty) {
          extractedName = lines[i].trim();
          break;
        }
      }
    }

    // Extract Aadhaar number from the last line that contains a valid 12-digit number
    final aadhaarPattern = RegExp(r'\b\d{4}\s?\d{4}\s?\d{4}\b');

    // Find the last line that contains a valid Aadhaar number
    for (int i = lines.length - 1; i >= 0; i--) {
      final line = lines[i].trim();
      final match = aadhaarPattern.firstMatch(line);
      if (match != null) {
        extractedAadhaarNumber =
            match.group(0)!.replaceAll(" ", ""); // Remove spaces
        break;
      }
    }

    setState(() {
      _name = extractedName;
      _aadhaarNumber = extractedAadhaarNumber;
    });
  }

  void _navigateToResultPage() {
    if (_aadhaarNumber != "Not detected" && _name != "Not detected") {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResultPage(
            imageFile: _selectedImage!,
            name: _name,
            aadhaarNumber: _aadhaarNumber,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please upload a valid Aadhaar card image."),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Aadhaar Validator"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Please upload an Aadhaar card image",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _selectedImage != null
                    ? Image.file(
                        _selectedImage!,
                        fit: BoxFit.cover,
                      )
                    : const Center(
                        child: Text("Tap to select an image"),
                      ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _selectedImage != null ? _navigateToResultPage : null,
              child: const Text("Submit"),
            ),
          ],
        ),
      ),
    );
  }
}
