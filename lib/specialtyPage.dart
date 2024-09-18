import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'ImageUpload.dart'; // Assuming you have ImageUpload.dart for Avatar widget
import 'constants.dart'; // Assuming you have constants.dart for client

// Define a custom class to hold specialty information
class Specialty {
  final String name;
  final String? imageUrl; // Store image URL directly

  Specialty({required this.name, this.imageUrl});
}

class AdminInterface extends StatefulWidget {
  @override
  _AdminInterfaceState createState() => _AdminInterfaceState();
}

class _AdminInterfaceState extends State<AdminInterface> {
  Map<String, String?> _imageUrls = {}; // Store image URLs in a Map
  TextEditingController _specialtyController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add specialty'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Avatar(
              imageUrl: _imageUrls[_specialtyController.text], // Use image URL from Map
              onUpload: (imageUrl) {
                setState(() {
                  _imageUrls[_specialtyController.text] = imageUrl!; // Update image URL in Map
                });
              },
            ),
            SizedBox(height: 20),
            TextField(
              controller: _specialtyController,
              decoration: InputDecoration(
                labelText: 'New Specialty',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                // Insert all specialties into the database
                await addNewSpecialty(
                  Specialty(
                    name: _specialtyController.text,
                    imageUrl: _imageUrls[_specialtyController.text],
                  ),
                );

                // Clear the text field after adding the specialty
                _specialtyController.clear();
              },
              child: Text('Save Specialty'),
            ),
          ],
        ),
      ),
    );
  }

  // Function to add a new specialty to the database
  Future<void> addNewSpecialty(Specialty specialty) async {
    try {
      // Check if the image URL is not null
      if (specialty.imageUrl != null) {
        // Insert the specialty into the database
        await client.from('specialty').insert({
          'name': specialty.name,
          'icon_path': specialty.imageUrl,
          // Add other fields if necessary
        });
        print('Specialty added: ${specialty.name}');
      } else {
        print('Error: Image URL is null');
      }
    } catch (error) {
      print('Error inserting new specialty: $error');
    }
  }
}
