import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pet_buddy/utils/colors.dart';
import 'package:pet_buddy/widgets/outline_text_field.dart';
import 'package:cool_alert/cool_alert.dart';  // Import CoolAlert

class DoctorCreate extends StatefulWidget {
  const DoctorCreate({super.key});

  @override
  State<DoctorCreate> createState() => _DoctorCreateState();
}

class _DoctorCreateState extends State<DoctorCreate> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _regNameController = TextEditingController();
  final TextEditingController _brController = TextEditingController();

  File? _image;
  bool _isLoading = false; // Add a loading state

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _image = File(image.path);
      });
    }
  }

  Future<void> _saveDoctorData() async {
    final String name = _nameController.text;
    final String email = _emailController.text;
    final String password = _passwordController.text;
    final String contact = _contactController.text;
    final String address = _addressController.text;
    final String regName = _regNameController.text;
    final String brNumber = _brController.text;

    if (name.isEmpty || email.isEmpty || password.isEmpty || contact.isEmpty || address.isEmpty || regName.isEmpty
        || brNumber.isEmpty) {
      // Handle empty fields
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    setState(() {
      _isLoading = true; // Show loader
    });

    try {
      // Create user in Firebase Authentication
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Get the user ID
      String userId = userCredential.user!.uid;

      // Save additional details to Firestore
      await FirebaseFirestore.instance.collection('doctors').doc(userId).set({
        'name': name,
        'profile_image': '',
        'email': email,
        'contact': contact,
        'address': address,
        'registered_name': regName,
        'business_registration_number': brNumber,
        'role': 'doctor',
      });

      // Show success alert
      CoolAlert.show(
        context: context,
        type: CoolAlertType.success,
        title: 'Success!',
        text: 'Doctor created successfully',
        onConfirmBtnTap: () {
          Navigator.of(context).pop(); // Go back
        },
      );

    } on FirebaseAuthException catch (e) {
      // Handle errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.message}')),
      );
    } finally {
      setState(() {
        _isLoading = false; // Hide loader
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(scaffoldBackgroundColor: Colors.white),
      debugShowCheckedModeBanner: false,
      title: 'Doctor Create',
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: secondaryColor,
          leading: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white)),
          title: const Text("Create Doctor", style: TextStyle(color: Colors.white)),
          centerTitle: true,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Uncomment and use the image picker widget if needed
                  // Stack(
                  //   children: [
                  //     GestureDetector(
                  //       onTap: _pickImage,
                  //       child: CircleAvatar(
                  //         radius: 60.0,
                  //         backgroundImage: _image != null ? FileImage(_image!) : null,
                  //         child: _image == null
                  //             ? const SizedBox()
                  //             : null,
                  //       ),
                  //     ),
                  //     if (_image == null)
                  //       Positioned(
                  //         bottom: 0,
                  //         right: 0,
                  //         child: GestureDetector(
                  //           onTap: _pickImage,
                  //           child: Container(
                  //             width: 40,
                  //             height: 40,
                  //             decoration: BoxDecoration(
                  //               shape: BoxShape.circle,
                  //               color: Colors.grey.withOpacity(0.5),
                  //             ),
                  //             child: const Icon(
                  //               Icons.add_photo_alternate,
                  //               size: 25,
                  //               color: Colors.white,
                  //             ),
                  //           ),
                  //         ),
                  //       ),
                  //     if (_image != null)
                  //       Positioned(
                  //         bottom: 0,
                  //         right: 0,
                  //         child: GestureDetector(
                  //           onTap: _pickImage,
                  //           child: Container(
                  //             width: 40,
                  //             height: 40,
                  //             decoration: BoxDecoration(
                  //               shape: BoxShape.circle,
                  //               color: Colors.grey.withOpacity(0.5),
                  //             ),
                  //             child: const Icon(
                  //               Icons.edit,
                  //               size: 25,
                  //               color: Colors.white,
                  //             ),
                  //           ),
                  //         ),
                  //       ),
                  //   ],
                  // ),
                  const SizedBox(height: 15),
                  OutlineTextField(
                      textEditingController: _nameController, labelText: 'User Name'),
                  const SizedBox(height: 10),
                  OutlineTextField(
                      textEditingController: _emailController, labelText: 'Email'),
                  const SizedBox(height: 10),
                  OutlineTextField(
                      textEditingController: _passwordController, labelText: 'Password',),
                  const SizedBox(height: 10),
                  OutlineTextField(
                      textEditingController: _contactController, labelText: 'Contact Number'),
                  const SizedBox(height: 10),
                  OutlineTextField(
                      textEditingController: _addressController, labelText: 'Address'),
                  const SizedBox(height: 10),
                  OutlineTextField(
                      textEditingController: _regNameController, labelText: 'Registered Name'),
                  const SizedBox(height: 10),
                  OutlineTextField(
                      textEditingController: _brController, labelText: 'Business Registration Number'),
                  const SizedBox(height: 30),
                  InkWell(
                    onTap: () async {
                      await _saveDoctorData();
                    },
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
                      child: _isLoading
                          ? const CircularProgressIndicator(
                        color: Colors.white,
                      )
                          : const Text(
                        'Create',
                        style: TextStyle(color: Colors.white, fontSize: 15),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
