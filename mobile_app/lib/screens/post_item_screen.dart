import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';

class PostItemScreen extends StatefulWidget {
  final String type; // 'lost' or 'found'

  PostItemScreen({required this.type});

  @override
  _PostItemScreenState createState() => _PostItemScreenState();
}

class _PostItemScreenState extends State<PostItemScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _itemNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _rewardController = TextEditingController();

  DateTime? _dateLost;
  LatLng? _lastSeenLocation;
  File? _imageFile;
  String? _category;

  bool _loading = false;

  final List<String> _categories = [
    'Keys',
    'Wallet',
    'Pet',
    'Mobile',
    'Other',
  ];

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _pickDate() async {
    DateTime now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 5),
      lastDate: now,
    );
    if (picked != null) {
      setState(() {
        _dateLost = picked;
      });
    }
  }

  Future<void> _pickLocation() async {
    // For simplicity, this example uses a fixed location picker dialog.
    // In a real app, integrate Google Maps picker here.
    LatLng selectedLocation = LatLng(37.7749, -122.4194); // San Francisco example
    setState(() {
      _lastSeenLocation = selectedLocation;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Location selected: ${selectedLocation.latitude}, ${selectedLocation.longitude}')),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_lastSeenLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please select last seen location')));
      return;
    }
    if (_dateLost == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please select date lost/found')));
      return;
    }
    if (_category == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please select category')));
      return;
    }

    setState(() {
      _loading = true;
    });

    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('User not logged in')));
      setState(() {
        _loading = false;
      });
      return;
    }

    // TODO: Upload image to Firebase Storage and get URL if _imageFile is not null
    String? photoUrl;

    await FirebaseFirestore.instance.collection('posts').add({
      'userId': user.uid,
      'itemName': _itemNameController.text.trim(),
      'description': _descriptionController.text.trim(),
      'lastSeenLocation': GeoPoint(_lastSeenLocation!.latitude, _lastSeenLocation!.longitude),
      'dateLost': Timestamp.fromDate(_dateLost!),
      'photoUrl': photoUrl,
      'category': _category,
      'reward': _rewardController.text.isNotEmpty ? double.tryParse(_rewardController.text) : null,
      'type': widget.type,
      'createdAt': Timestamp.now(),
    });

    setState(() {
      _loading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Post submitted successfully')));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.type == 'lost' ? 'Post Lost Item' : 'Post Found Item'),
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      controller: _itemNameController,
                      decoration: InputDecoration(labelText: 'Item Name'),
                      validator: (value) => value == null || value.isEmpty ? 'Please enter item name' : null,
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: InputDecoration(labelText: 'Description'),
                      maxLines: 3,
                      validator: (value) => value == null || value.isEmpty ? 'Please enter description' : null,
                    ),
                    SizedBox(height: 10),
                    ListTile(
                      title: Text(_lastSeenLocation == null
                          ? 'Select Last Seen Location'
                          : 'Location: ${_lastSeenLocation!.latitude}, ${_lastSeenLocation!.longitude}'),
                      trailing: Icon(Icons.map),
                      onTap: _pickLocation,
                    ),
                    SizedBox(height: 10),
                    ListTile(
                      title: Text(_dateLost == null
                          ? 'Select Date Lost/Found'
                          : 'Date: ${_dateLost!.toLocal().toString().split(' ')[0]}'),
                      trailing: Icon(Icons.calendar_today),
                      onTap: _pickDate,
                    ),
                    SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(labelText: 'Category'),
                      items: _categories
                          .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                          .toList(),
                      onChanged: (val) {
                        setState(() {
                          _category = val;
                        });
                      },
                      validator: (value) => value == null ? 'Please select category' : null,
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      controller: _rewardController,
                      decoration: InputDecoration(labelText: 'Reward (optional)'),
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: 10),
                    _imageFile == null
                        ? TextButton.icon(
                            onPressed: _pickImage,
                            icon: Icon(Icons.photo),
                            label: Text('Upload Photo'),
                          )
                        : Image.file(_imageFile!),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _submit,
                      child: Text('Submit'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
