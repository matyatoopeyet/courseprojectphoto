import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'photo_gallery_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();  // Initialize Firebase
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firebase Photo Gallery',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: PhotoGalleryScreen(),
    );
  }
}
