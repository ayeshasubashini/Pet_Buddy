import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pet_buddy/utils/colors.dart';
import 'package:pet_buddy/widgets/outline_text_field.dart';
import 'package:cool_alert/cool_alert.dart';

class PetCreate extends StatefulWidget {
  const PetCreate({super.key});

  @override
  State<PetCreate> createState() => _PetCreateState();
}

class _PetCreateState extends State<PetCreate> {
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
  File? _image;
  DateTime? _selectedDate;
  DateTime? _selectedVaccinatedDate;
  bool _isLoading = false; // Loading state for the button

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
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
    if (picked != null) {
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
    if (picked != null) {
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
    if (today.day < birthDate.day) {
      months--;
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

  Future<String?> _uploadImageToFirebase(File image) async {
    try {
      final ref = _storage.ref().child('pet_images/${DateTime.now()}.jpg');
      final uploadTask = await ref.putFile(image);
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      return null;
    }
  }

  Future<void> createPet() async {
    if (_image == null) {
      CoolAlert.show(
        context: context,
        type: CoolAlertType.error,
        text: "Please select an image",
      );
      return;
    }
    
    setState(() {
      _isLoading = true; // Start loading
    });

    var hive = await Hive.openBox('loginBox');
    String? uid = hive.get("uid");

    try {
      final imageUrl = await _uploadImageToFirebase(_image!);
      if (imageUrl != null) {
        await _firestore.collection("pets").add({
          "user_ref": uid,
          "image": imageUrl,
          "name": nameController.text,
          "type": petTypeController.text,
          "breed": breedController.text,
          "gender": _selectedGender,
          "dob": dobController.text,
          "age": ageController.text,
          "prev_vaccinated": vaccinationController.text,
          "next_vaccinate" : "",
        });
        setState(() {
          _isLoading = false; // Stop loading
        });
        CoolAlert.show(
          context: context,
          type: CoolAlertType.success,
          text: "Pet created successfully!",
        );
      } else {
        setState(() {
          _isLoading = false; // Stop loading
        });
        CoolAlert.show(
          context: context,
          type: CoolAlertType.error,
          text: "Failed to upload image.",
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false; // Stop loading
      });
      CoolAlert.show(
        context: context,
        type: CoolAlertType.error,
        text: "Error occurred while creating pet.",
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(scaffoldBackgroundColor: Colors.white),
      debugShowCheckedModeBanner: false,
      title: 'Pets Create Form',
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: secondaryColor,
          leading: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white)),
          title: const Text('Create Pets', style: TextStyle(color: Colors.white)),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Center(
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
                              : null,
                        ),
                        child: _image == null
                            ? const Center(
                                child: Icon(Icons.add, color: Colors.white, size: 50),
                              )
                            : null,
                      ),
                      if (_image != null)
                        const Positioned(
                          bottom: 8,
                          right: 8,
                          child: CircleAvatar(
                            backgroundColor: Colors.black54,
                            radius: 18,
                            child: Icon(Icons.edit, color: Colors.white, size: 20),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 15),
                OutlineTextField(textEditingController: nameController, labelText: 'Name'),
                const SizedBox(height: 15),
                OutlineTextField(textEditingController: petTypeController, labelText: 'Pet Type'),
                const SizedBox(height: 15),
                OutlineTextField(textEditingController: breedController, labelText: 'Breed'),
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
                      borderSide: BorderSide(color: secondaryColor),
                    ),
                    floatingLabelStyle: TextStyle(color: secondaryColor),
                  ),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedGender = newValue;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a gender';
                    }
                    return null;
                  },
                  items: _genders.map<DropdownMenuItem<String>>((String gender) {
                    return DropdownMenuItem<String>(
                      value: gender,
                      child: Text(gender),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: dobController,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: 'Date of Birth',
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide(color: secondaryColor),
                    ),
                    floatingLabelStyle: const TextStyle(color: secondaryColor),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.calendar_today, color: Colors.black54),
                      onPressed: () => _selectDate(context),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                OutlineTextField(textEditingController: ageController, labelText: 'Age', readOnly: true),
                const SizedBox(height: 15),
                TextFormField(
                  controller: vaccinationController,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: 'Last Vaccinated Date',
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide(color: secondaryColor),
                    ),
                    floatingLabelStyle: const TextStyle(color: secondaryColor),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.calendar_today, color: Colors.black54),
                      onPressed: () => _selectVaccinatedDate(context),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                ElevatedButton(
                  onPressed: _isLoading ? null : createPet,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    backgroundColor: secondaryColor,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(
                          color: Colors.white, // Set the progress indicator color to white
                        )
                      : const Text(
                          'Create',
                          style: TextStyle(color: Colors.white), // Set text color to white
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
