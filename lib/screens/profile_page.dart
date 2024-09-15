import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pet_buddy/screens/login_page.dart';
import 'package:pet_buddy/widgets/outline_text_field.dart';
import '../utils/colors.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  File? _image;
  bool _isLoading = false;
  String? _existingImageUrl; // To store existing image URL

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    var box = await Hive.openBox('loginBox');
    String? email = box.get('email');
    if (email != null) {
      // Fetch the current user data from Firestore
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('userdetails')
          .where('email', isEqualTo: email)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        DocumentSnapshot userData = querySnapshot.docs.first;

        setState(() {
          emailController.text = userData.get('email');
          nameController.text = userData.get('user_name');
          _existingImageUrl = userData.get('profile_image'); // Get existing image URL
        });
      } else {
        setState(() {
          emailController.text = 'No email found';
          nameController.text = '';
        });
      }
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _image = File(image.path);
      });
    }
  }

  Future<void> _updateUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get the email from the controller (since it's already loaded)
      String email = emailController.text;

      // Reference to the Firestore document
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('userdetails')
          .where('email', isEqualTo: email)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        DocumentSnapshot userDoc = querySnapshot.docs.first;

        // Check if the user has selected a new image
        String? imageUrl = _existingImageUrl;
        if (_image != null) {
          // Upload the image to Firebase Storage if a new one is selected
          final ref = FirebaseStorage.instance
              .ref()
              .child('user_images')
              .child('$email.jpg');
          await ref.putFile(_image!);
          imageUrl = await ref.getDownloadURL(); // New image URL
        }

        // Update Firestore document with the new data
        await FirebaseFirestore.instance
            .collection('userdetails')
            .doc(userDoc.id)
            .update({
          'user_name': nameController.text,
          if (imageUrl != null) 'profile_image': imageUrl, // Update or set image
        });

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
      }
    } catch (e) {
      // Show error message if the update fails
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update profile: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void logout() {
    saveLoggingData();
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginPage()));
  }

  void saveLoggingData() async {
    var box = await Hive.openBox('loginBox');
    box.put('login_state', 'logged_out');
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(scaffoldBackgroundColor: Colors.white),
      debugShowCheckedModeBanner: false,
      title: 'Profile',
      home: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 50),
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Profile Image
                  GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 60.0,
                      backgroundImage:
                      _image != null ? FileImage(_image!) : _existingImageUrl != null ? NetworkImage(_existingImageUrl!) : null,
                      child: (_image == null && _existingImageUrl == null)
                          ? const Icon(Icons.add_photo_alternate,
                          size: 50, color: Colors.grey)
                          : null,
                    ),
                  ),
                  const SizedBox(height: 15),
                  OutlineTextField(
                    textEditingController: nameController,
                    labelText: 'User Name',
                  ),
                  const SizedBox(height: 10),
                  OutlineTextField(
                    textEditingController: emailController,
                    readOnly: true,
                    labelText: 'Email',
                  ),
                  const SizedBox(height: 30),
                  _isLoading
                      ? const CircularProgressIndicator()
                      : InkWell(
                    onTap: _updateUserData,
                    child: Container(
                      width: double.infinity,
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      decoration: const ShapeDecoration(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(10),
                          ),
                        ),
                        color: secondaryColor,
                      ),
                      child: const Text(
                        'Update',
                        style:
                        TextStyle(color: Colors.white, fontSize: 15),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  InkWell(
                    onTap: logout,
                    child: Container(
                      width: 100,
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      decoration: const ShapeDecoration(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(10),
                          ),
                        ),
                        color: Colors.red,
                      ),
                      child: const Text(
                        'Logout',
                        style: TextStyle(color: Colors.white, fontSize: 15),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
