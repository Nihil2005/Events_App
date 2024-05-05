import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class UploadEventPage extends StatefulWidget {
  @override
  _UploadEventPageState createState() => _UploadEventPageState();
}

class _UploadEventPageState extends State<UploadEventPage> {
  File? _image;
  final picker = ImagePicker();
  TextEditingController _titleController = TextEditingController();
  TextEditingController _contentController = TextEditingController();

  Future getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    });
  }

  void uploadEvent() async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('http://192.168.32.1:800/events/'),
    );
    request.fields['title'] = _titleController.text;
    request.fields['content'] = _contentController.text;
    request.files.add(
      await http.MultipartFile.fromPath('image', _image!.path),
    );

    var response = await request.send();
    if (response.statusCode == 201) {
      // Event uploaded successfully
      print('Event uploaded successfully');
    } else {
      // Error uploading event
      print('Error uploading event');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upload Event'),
      ),
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: [
          _image == null ? Text('No image selected.') : Image.file(_image!),
          ElevatedButton(
            onPressed: getImage,
            child: Text('Select Image'),
          ),
          TextField(
            controller: _titleController,
            decoration: InputDecoration(
              hintText: 'Enter title',
            ),
          ),
          SizedBox(height: 16.0),
          TextField(
            controller: _contentController,
            decoration: InputDecoration(
              hintText: 'Enter content',
            ),
          ),
          SizedBox(height: 16.0),
          ElevatedButton(
            onPressed: _image == null ||
                    _titleController.text.isEmpty ||
                    _contentController.text.isEmpty
                ? null
                : uploadEvent,
            child: Text('Upload Event'),
          ),
        ],
      ),
    );
  }
}
