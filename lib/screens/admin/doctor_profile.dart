import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cool_alert/cool_alert.dart';  // Import CoolAlert
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pet_buddy/utils/colors.dart';
import 'package:pet_buddy/widgets/outline_text_field.dart';

class DoctorProfile extends StatefulWidget {
  final String doctorId;  // UID for the doctor passed from the previous screen

  const DoctorProfile({super.key, required this.doctorId});

  @override
  State<DoctorProfile> createState() => _DoctorProfileState();
}

class _DoctorProfileState extends State<DoctorProfile> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _regNameController = TextEditingController();
  final TextEditingController _brController = TextEditingController();

  File? _image;
  bool _isLoading = false;  // For loading indicator

  // Pick image from gallery
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _image = File(image.path);
      });
    }
  }

  // Load doctor details from Firebase
  Future<void> _loadDoctorDetails() async {
    setState(() {
      _isLoading = true;
    });

    final doctorDoc = await FirebaseFirestore.instance
        .collection('doctors')
        .doc(widget.doctorId)
        .get();

    if (doctorDoc.exists) {
      final doctorData = doctorDoc.data() as Map<String, dynamic>;
      setState(() {
        _nameController.text = doctorData['name'] ?? '';
        _emailController.text = doctorData['email'] ?? '';
        _contactController.text = doctorData['contact'] ?? '';
        _addressController.text = doctorData['address'] ?? '';
        _regNameController.text = doctorData['registered_name'] ?? '';
        _brController.text = doctorData['business_registration_number'] ?? '';
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  // Update doctor details in Firebase
  Future<void> _updateDoctorDetails() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseFirestore.instance.collection('doctors').doc(widget.doctorId).update({
        'name': _nameController.text,
        'contact': _contactController.text,
        'address': _addressController.text,
        'registered_name': _regNameController.text,
        'business_registration_number': _brController.text,
      });

      // Show success alert after saving data
      CoolAlert.show(
        context: context,
        type: CoolAlertType.success,
        text: "Doctor details updated successfully!",
        onConfirmBtnTap: () {
          Navigator.of(context).pop();  // Close the alert
        },
      );
    } catch (e) {
      CoolAlert.show(
        context: context,
        type: CoolAlertType.error,
        text: "Failed to update details: $e",
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadDoctorDetails();  // Load doctor details when the screen is initialized
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(scaffoldBackgroundColor: Colors.white),
      debugShowCheckedModeBanner: false,
      title: 'Doctor Profile',
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: secondaryColor,
          leading: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white)),
          title: const Text("Doctor's Profile", style: TextStyle(color: Colors.white)),
          centerTitle: true,
        ),
        body: SafeArea(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())  // Show loading indicator
              : SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 15),
                  OutlineTextField(
                      textEditingController: _nameController,
                      labelText: 'User Name'),
                  const SizedBox(height: 10),
                  OutlineTextField(
                      textEditingController: _emailController,
                      readOnly: true,
                      labelText: 'Email'),
                  const SizedBox(height: 10),
                  OutlineTextField(
                      textEditingController: _contactController,
                      labelText: 'Contact Number'),
                  const SizedBox(height: 10),
                  OutlineTextField(
                      textEditingController: _addressController,
                      labelText: 'Address'),
                  const SizedBox(height: 10),
                  OutlineTextField(
                      textEditingController: _regNameController,
                      labelText: 'Registered Name'),
                  const SizedBox(height: 10),
                  OutlineTextField(
                      textEditingController: _brController,
                      labelText: 'Business Registration Number'),
                  const SizedBox(height: 30),
                  InkWell(
                    onTap: _updateDoctorDetails,  // Update doctor details
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
