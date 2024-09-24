import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:shape_dec/ar_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  File? _selectedImage;
  bool _isGallerySelected = false;

  Future<void> _pickImageFromGallery() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (image != null) {
        _selectedImage = File(image.path);
        _isGallerySelected = true;
      }
    });
  }

  Future<void> _pickImageFromCamera() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);
    setState(() {
      if (image != null) {
        _selectedImage = File(image.path);
        _isGallerySelected = false;
      }
    });
  }

  Future<String?> imageProcess(String path) async {
    // final apiKey = Platform.environment['AIzaSyCWMrbbfq_WL3iWaB-74ak-LlhYYU1e7e8'];
    const apiKey = 'AIzaSyAu1zXvT1aYRo4mO6OGaR0aL7VTodmn5cA';

    // print('API_KEY: $apiKey');
    if (apiKey == null) {
      print('No \$API_KEY environment variable');
      exit(1);
    }

    final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey);

    try {
      final imageBytes = await File(path).readAsBytes();

      final prompt = TextPart(
        "Detect the shape which is being drawn on the Image and output name only 1 word",
      );
      final imagePart = DataPart('image/jpeg', imageBytes);

      final response = await model.generateContent([
        Content.multi([prompt, imagePart])
      ]);

      if (response != null && response.text != null) {
        print(response.text);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ShapeDisplayPage(
              // const CameraDescription(
              //     sensorOrientation: 90,
              //     lensDirection: CameraLensDirection.back,
              //     name: ''),
              shapename: response.text??'Circle',
            ),
          ),
        );

        return response.text;
      } else {
        print('No text response received.');
        return null;
      }
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Shape Detector')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Switch(
                  value: _isGallerySelected,
                  onChanged: (bool value) {
                    setState(() {
                      _isGallerySelected = value;
                    });
                  },
                ),
                ElevatedButton(
                  onPressed: _isGallerySelected
                      ? _pickImageFromGallery
                      : _pickImageFromCamera,
                  child:
                      Text(_isGallerySelected ? 'From Gallery' : 'From Camera'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _selectedImage != null
                  ? () => imageProcess(_selectedImage!.path)
                  : null,
              child: const Text('Detect Shapes'),
            ),
          ],
        ),
      ),
    );
  }
}
