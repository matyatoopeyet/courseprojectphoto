import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class PhotoGalleryScreen extends StatefulWidget {
  @override
  _PhotoGalleryScreenState createState() => _PhotoGalleryScreenState();
}

class _PhotoGalleryScreenState extends State<PhotoGalleryScreen> {
  final ImagePicker _picker = ImagePicker();
  late FirebaseStorage storage;

  @override
  void initState() {
    super.initState();
    storage = FirebaseStorage.instance;
  }

  // Function to pick an image from the gallery
  Future<void> pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      uploadImageToFirebase(imageFile);
    }
  }

  // Uploading image to Firebase Storage
  Future<void> uploadImageToFirebase(File imageFile) async {
    try {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();  // Create a unique file name
      Reference reference = storage.ref().child('photos/$fileName');

      await reference.putFile(imageFile);
      String downloadUrl = await reference.getDownloadURL();

      // Here you would save the downloadUrl to Firestore if you want to store it
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Image uploaded successfully! URL: $downloadUrl")));
    } catch (e) {
      print(e.toString());
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to upload image")));
    }
  }

  // Fetch and display images from Firebase Storage
  Future<List<String>> fetchImages() async {
    List<String> imageUrls = [];
    try {
      final ListResult result = await storage.ref('photos').listAll();
      for (var item in result.items) {
        String url = await item.getDownloadURL();
        imageUrls.add(url);
      }
    } catch (e) {
      print(e.toString());
    }
    return imageUrls;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Firebase Photo Gallery')),
      body: FutureBuilder<List<String>>(
        future: fetchImages(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error fetching images'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No images uploaded'));
          } else {
            List<String> imageUrls = snapshot.data!;
            return GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
              ),
              itemCount: imageUrls.length,
              itemBuilder: (context, index) {
                return Image.network(imageUrls[index]);
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: pickImage,
        child: Icon(Icons.add_a_photo),
        tooltip: 'Pick Image',
      ),
    );
  }
}
