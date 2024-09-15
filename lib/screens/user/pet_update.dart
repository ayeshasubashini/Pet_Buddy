import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:pet_buddy/utils/colors.dart';
import 'package:pet_buddy/widgets/outline_text_field.dart';

class PetUpdate extends StatefulWidget {
  final String petId; // Pass the pet ID to fetch the data from Firestore

  const PetUpdate({super.key, required this.petId});

  @override
  State<PetUpdate> createState() => _PetUpdateState();
}

class _PetUpdateState extends State<PetUpdate> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController breedController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController vaccinationController = TextEditingController();
  final TextEditingController petTypeController = TextEditingController();
  final TextEditingController genderController = TextEditingController();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  String? _selectedGender;
  final List<String> _genders = ['Male', 'Female', 'Other'];
  String? _imageUrl; // URL for the existing image
  File? _image;
  DateTime? _selectedDate;
  DateTime? _selectedVaccinatedDate;

  @override
  void initState() {
    super.initState();
    // Fetch the pet data when the page loads
    _fetchPetData();
  }

  Future<void> _fetchPetData() async {
    var snapshot = await _firestore.collection('pets').doc(widget.petId).get();
    if (snapshot.exists) {
      var petData = snapshot.data()!;
      setState(() {
        nameController.text = petData['name'];
        ageController.text = petData['age'];
        breedController.text = petData['breed'];
        dobController.text = petData['dob'];
        vaccinationController.text = petData['prev_vaccinated'];
        petTypeController.text = petData['type'];
        _selectedGender = petData['gender'];
        _imageUrl = petData['image']; // Fetch and load image URL
      });
    }
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _selectVaccinatedDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );

    if (picked != null && picked != _selectedVaccinatedDate) {
      setState(() {
        _selectedVaccinatedDate = picked;
        vaccinationController.text = "${picked.toLocal()}".split(' ')[0];
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        dobController.text = "${picked.toLocal()}".split(' ')[0];
        final age = _calculateAge(picked);
        ageController.text = _formatAge(age);
      });
    }
  }

  Map<String, int> _calculateAge(DateTime birthDate) {
    final today = DateTime.now();
    int years = today.year - birthDate.year;
    int months = today.month - birthDate.month;

    if (months < 0) {
      years--;
      months += 12;
    }

    return {'years': years, 'months': months};
  }

  String _formatAge(Map<String, int> age) {
    final years = age['years']!;
    final months = age['months']!;

    if (years > 0 && months > 0) {
      return "$years years $months months";
    } else if (years > 0) {
      return "$years years";
    } else if (months > 0) {
      return "$months months";
    } else {
      return "0";
    }
  }

  Future<void> _uploadImage(String petId) async {
    if (_image != null) {
      final imageName = path.basename(_image!.path);
      final storageRef = _storage.ref().child('pet_images/$petId/$imageName');
      await storageRef.putFile(_image!);
      _imageUrl = await storageRef.getDownloadURL();
    }
  }

  Future<void> updatePet() async {
    try {
      await _uploadImage(widget.petId); // Upload the image if selected

      await _firestore.collection("pets").doc(widget.petId).update({
        "user_ref": Hive.box('loginBox').get("uid"), // Ensure Hive is properly initialized
        "name": nameController.text,
        "type": petTypeController.text,
        "breed": breedController.text,
        "gender": _selectedGender,
        "dob": dobController.text,
        "age": ageController.text,
        "prev_vaccinated": vaccinationController.text,
        "image": _imageUrl, // Save the image URL to Firestore
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pet details updated successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update pet details: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: secondaryColor,
        leading: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: Colors.white,
            )),
        title: const Text('Pet Update', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          children: [
            const SizedBox(height: 30),
            GestureDetector(
              onTap: _pickImage,
              child: Stack(
                children: [
                  Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                      image: _image != null
                          ? DecorationImage(
                              image: FileImage(_image!),
                              fit: BoxFit.cover,
                            )
                          : _imageUrl != null
                              ? DecorationImage(
                                  image: NetworkImage(_imageUrl!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                    ),
                    child: _image == null && _imageUrl == null
                        ? const Center(
                            child: Icon(
                              Icons.add,
                              color: Colors.white,
                              size: 50,
                            ),
                          )
                        : null,
                  ),
                  if (_image != null || _imageUrl != null)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: IconButton(
                        icon: const Icon(Icons.edit, color: Colors.white),
                        onPressed: _pickImage,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 15),
            OutlineTextField(
                textEditingController: nameController, labelText: 'Name'),
            const SizedBox(height: 15),
            OutlineTextField(
                textEditingController: petTypeController, labelText: 'Pet Type'),
            const SizedBox(height: 15),
            OutlineTextField(
                textEditingController: breedController, labelText: 'Breed'),
            const SizedBox(height: 15),
            DropdownButtonFormField<String>(
              value: _selectedGender,
              hint: const Text('Select Gender'),
              decoration: const InputDecoration(
                labelText: 'Gender',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  borderSide: BorderSide(
                    color: secondaryColor,
                    width: 2,
                  ),
                ),
              ),
              items: _genders.map((String gender) {
                return DropdownMenuItem<String>(
                  value: gender,
                  child: Text(gender),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedGender = value;
                });
              },
            ),
            const SizedBox(height: 15),
            GestureDetector(
              onTap: () => _selectDate(context),
              child: AbsorbPointer(
                child: OutlineTextField(
                  textEditingController: dobController,
                  labelText: 'Date of Birth',
                ),
              ),
            ),
            const SizedBox(height: 15),
            GestureDetector(
              onTap: () => _selectVaccinatedDate(context),
              child: AbsorbPointer(
                child: OutlineTextField(
                  textEditingController: vaccinationController,
                  labelText: 'Previous Vaccinated Date',
                ),
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: secondaryColor,
                ),
                onPressed: updatePet,
                child: const Text('Update Pet'),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
