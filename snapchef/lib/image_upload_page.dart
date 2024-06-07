import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';

class ImageUploadPage extends StatefulWidget {
  @override
  _ImageUploadPageState createState() => _ImageUploadPageState();
}

class _ImageUploadPageState extends State<ImageUploadPage> {
  File? _image;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    } else {
      print('No image selected.');
    }
  }

  Future<void> _uploadImage() async {
    if (_image == null) return;

    final uri = Uri.parse('https://curly-space-potato-76wg9w9wx5vcg7j-5000.app.github.dev/upload');
    final mimeTypeData = lookupMimeType(_image!.path, headerBytes: [0xFF, 0xD8])?.split('/');

    if (mimeTypeData == null || mimeTypeData.length != 2) {
      print('Could not determine mime type!');
      return;
    }

    final imageUploadRequest = http.MultipartRequest('POST', uri)
      ..files.add(
        http.MultipartFile(
          'photo',
          _image!.readAsBytes().asStream(),
          _image!.lengthSync(),
          filename: basename(_image!.path),
          contentType: MediaType(mimeTypeData[0], mimeTypeData[1]),
        ),
      );

    try {
      final response = await imageUploadRequest.send();
      if (response.statusCode == 200) {
        print('Image uploaded successfully.');
      } else {
        print('Image upload failed with status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error during upload: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upload Photo'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _image == null ? Text('No image selected.') : Image.file(_image!),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _pickImage,
              child: Text('Pick Image from Gallery'),
            ),
            ElevatedButton(
              onPressed: _uploadImage,
              child: Text('Upload Image'),
            ),
          ],
        ),
      ),
    );
  }
}
