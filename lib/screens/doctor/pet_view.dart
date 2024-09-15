import 'package:flutter/material.dart';
import 'package:pet_buddy/screens/doctor/qr_scanner.dart';
import 'package:pet_buddy/utils/colors.dart';
import 'package:pet_buddy/widgets/outline_text_field.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cool_alert/cool_alert.dart'; // Import cool_alert package

class PetView extends StatefulWidget {
  final String qrData; // Add qrData as a field

  const PetView({super.key, required this.qrData});

  @override
  State<PetView> createState() => _PetViewState();
}

class _PetViewState extends State<PetView> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController breedController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController vaccinationController = TextEditingController();
  final TextEditingController petTypeController = TextEditingController();
  final TextEditingController genderController = TextEditingController();
  String? imageUrl; // Field for storing the image URL
  DateTime? nextVaccinationDate; // Next vaccination date
  final TextEditingController nextVaccinationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadPetData();
  }

  Future<void> _loadPetData() async {
    try {
      // Fetch pet data from Firebase
      DocumentSnapshot petDoc = await FirebaseFirestore.instance
          .collection('pets') // Replace with your collection name
          .doc(widget.qrData) // Use the QR data as the document ID
          .get();

      if (petDoc.exists) {
        var data = petDoc.data() as Map<String, dynamic>;

        // Populate fields with fetched data
        nameController.text = data['name'] ?? '';
        petTypeController.text = data['petType'] ?? '';
        breedController.text = data['breed'] ?? '';
        genderController.text = data['gender'] ?? '';
        dobController.text = data['dob'] ?? '';
        ageController.text = data['age'] ?? '';
        vaccinationController.text = data['prev_vaccinated'] ?? '';
        imageUrl = data['image'] ?? ''; // Load image URL
      } else {
        // Handle case where the pet document does not exist
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pet not found')),
        );
      }
    } catch (e) {
      // Handle errors
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error fetching pet data')),
      );
    }
    setState(() {}); // Update the UI after loading data
  }

  Future<void> _saveVaccinationData() async {
    try {
      // Save vaccination history in Firestore
      await FirebaseFirestore.instance.collection('vaccination_history').add({
        'petName': nameController.text,
        'ownerEmail': 'owner@example.com', // Replace with real owner email
        'doctorName': 'Dr. Smith', // Replace with real doctor name
        'doctorRegNumber': '12345', // Replace with real doctor registered number
        'nextVaccinationDate': nextVaccinationDate?.toIso8601String(),
        'previousVaccinationDate': vaccinationController.text,
        'qrData': widget.qrData,
      });

      // Show success message using CoolAlert
      CoolAlert.show(
        context: context,
        type: CoolAlertType.success,
        text: 'Vaccination data saved successfully!',
      );
    } catch (e) {
      // Handle errors
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error saving vaccination data')),
      );
    }
  }

  Future<void> _showVaccinationPopup() async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Enter Next Vaccination Date'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(
                  hintText: 'Pick Next Vaccination Date',
                ),
                onTap: () async {
                  // Date picker for the next vaccination date
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                  if (pickedDate != null) {
                    setState(() {
                      nextVaccinationDate = pickedDate;
                      nextVaccinationController.text =
                          "${pickedDate.year}-${pickedDate.month}-${pickedDate.day}"; // Update text field
                    });
                  }
                },
                readOnly: true,
                controller: nextVaccinationController, // Use the controller here
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close popup
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                await _saveVaccinationData(); // Save the vaccination data
                Navigator.of(context).pop(); // Close popup after saving
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(scaffoldBackgroundColor: Colors.white),
      debugShowCheckedModeBanner: false,
      title: 'Pet View',
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: secondaryColor,
          leading: IconButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => const QrScanner()));
              },
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white)),
          title: const Text("Pet Detail", style: TextStyle(color: Colors.white)),
          centerTitle: true,
        ),
        body: SafeArea(
            child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Center(
              child: Column(
                children: [
                  const SizedBox(height: 15),
                  if (imageUrl != null && imageUrl!.isNotEmpty)
                    Container(
                      height: 150,
                      width: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: NetworkImage(imageUrl!),
                          fit: BoxFit.cover,
                        ),
                      ),
                    )
                  else
                    const Icon(Icons.pets, size: 100, color: Colors.grey),
                  const SizedBox(height: 15),
                  OutlineTextField(
                    textEditingController: nameController,
                    labelText: 'Name',
                    readOnly: true,
                  ),
                  const SizedBox(height: 15),
                  OutlineTextField(
                    textEditingController: petTypeController,
                    labelText: 'Pet Type',
                    readOnly: true,
                  ),
                  const SizedBox(height: 15),
                  OutlineTextField(
                    textEditingController: breedController,
                    labelText: 'Breed',
                    readOnly: true,
                  ),
                  const SizedBox(height: 15),
                  OutlineTextField(
                    textEditingController: genderController,
                    labelText: 'Gender',
                    readOnly: true,
                  ),
                  const SizedBox(height: 15),
                  OutlineTextField(
                    textEditingController: dobController,
                    labelText: 'Date of Birth',
                    readOnly: true,
                  ),
                  const SizedBox(height: 15),
                  OutlineTextField(
                    textEditingController: ageController,
                    labelText: 'Age',
                    readOnly: true,
                  ),
                  const SizedBox(height: 15),
                  OutlineTextField(
                    textEditingController: vaccinationController,
                    labelText: 'Previous Vaccinated Date',
                    readOnly: true,
                  ),
                  const SizedBox(height: 15),
                  ElevatedButton(
                    onPressed: _showVaccinationPopup,
                    child: const Text('Make pet vaccinated'),
                  ),
                  const SizedBox(height: 15),
                ],
              ),
            ),
          ),
        )),
      ),
    );
  }
}
