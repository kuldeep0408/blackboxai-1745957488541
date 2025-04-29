import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../models/user_model.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();

  File? _imageFile;
  String? _photoUrl;

  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    setState(() {
      _loading = true;
    });
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        UserModel userModel = UserModel.fromMap(doc.data() as Map<String, dynamic>);
        _nameController.text = userModel.name;
        _cityController.text = userModel.city;
        _photoUrl = userModel.photoUrl;
      }
    }
    setState(() {
      _loading = false;
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveProfile() async {
    setState(() {
      _loading = true;
    });
    User? user = _auth.currentUser;
    if (user != null) {
      String? photoUrl = _photoUrl;
      // TODO: Upload image to Firebase Storage and get URL if _imageFile is not null
      // For now, skipping image upload implementation

      UserModel userModel = UserModel(
        uid: user.uid,
        name: _nameController.text.trim(),
        photoUrl: photoUrl,
        city: _cityController.text.trim(),
        email: user.email ?? '',
      );

      await _firestore.collection('users').doc(user.uid).set(userModel.toMap());
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Profile saved')));
    }
    setState(() {
      _loading = false;
    });
  }

  Widget _buildProfileImage() {
    if (_imageFile != null) {
      return CircleAvatar(
        radius: 50,
        backgroundImage: FileImage(_imageFile!),
      );
    } else if (_photoUrl != null) {
      return CircleAvatar(
        radius: 50,
        backgroundImage: NetworkImage(_photoUrl!),
      );
    } else {
      return CircleAvatar(
        radius: 50,
        child: Icon(Icons.person, size: 50),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Profile'),
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.all(16),
              child: ListView(
                children: [
                  Center(
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: _buildProfileImage(),
                    ),
                  ),
                  SizedBox(height: 20),
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(labelText: 'Name'),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: _cityController,
                    decoration: InputDecoration(labelText: 'City/Locality'),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _saveProfile,
                    child: Text('Save Profile'),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => HomeScreen()),
                      );
                    },
                    child: Text('Go to Home Feed'),
                  ),
                ],
              ),
            ),
    );
  }
}
