import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cool_alert/cool_alert.dart'; // CoolAlert package
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pet_buddy/utils/colors.dart';
import 'package:pet_buddy/widgets/outline_text_field.dart';
import 'map_screen.dart'; // Import the map screen

class PetCaresCreate extends StatefulWidget {
  const PetCaresCreate({super.key});

  @override
  State<PetCaresCreate> createState() => _PetCaresCreateState();
}

class _PetCaresCreateState extends State<PetCaresCreate> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _latitudeController = TextEditingController();
  final TextEditingController _longitudeController = TextEditingController();
  LatLng? _selectedLocation;

  bool _isLoading = false; // For loading spinner

  // Function to pick location using MapScreen
  void _pickLocation() async {
    final LatLng? location = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MapScreen(
          onLocationPicked: (LatLng pickedLocation) {
            setState(() {
              _selectedLocation = pickedLocation;
              _latitudeController.text = _selectedLocation!.latitude.toString();
              _longitudeController.text = _selectedLocation!.longitude.toString();
            });
          },
        ),
      ),
    );
  }

  // Function to save the pet care details to Firebase
  Future<void> _savePetCare() async {
    if (_nameController.text.isEmpty || _addressController.text.isEmpty || _selectedLocation == null) {
      CoolAlert.show(
        context: context,
        type: CoolAlertType.error,
        text: "Please fill in all fields and select a location",
      );
      return;
    }

    setState(() {
      _isLoading = true;  // Start loading
    });

    try {
      await FirebaseFirestore.instance.collection('petCares').add({
        'name': _nameController.text,
        'address': _addressController.text,
        'latitude': _latitudeController.text,
        'longitude': _longitudeController.text,
      });

      // Show success CoolAlert
      CoolAlert.show(
        context: context,
        type: CoolAlertType.success,
        text: "Pet care details saved successfully!",
        onConfirmBtnTap: () {
          Navigator.of(context).pop();  // Close the alert
        },
      );
    } catch (e) {
      // Show error CoolAlert in case of failure
      CoolAlert.show(
        context: context,
        type: CoolAlertType.error,
        text: "Failed to save details: $e",
      );
    }

    setState(() {
      _isLoading = false;  // Stop loading
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(scaffoldBackgroundColor: Colors.white),
      debugShowCheckedModeBanner: false,
      title: 'Pet Care Create',
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: secondaryColor,
          leading: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
              )),
          title: const Text(
            'Create Pet Care',
            style: TextStyle(color: Colors.white),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              children: [
                const SizedBox(height: 30),
                OutlineTextField(
                    textEditingController: _nameController, labelText: 'Name'),
                const SizedBox(height: 15),
                OutlineTextField(
                    textEditingController: _addressController, labelText: 'Address'),
                const SizedBox(height: 15),
                ElevatedButton.icon(
                  onPressed: _pickLocation,
                  icon: const Icon(Icons.add_location_alt),
                  label: const Text(
                    'Pick Location',
                    style: TextStyle(color: secondaryColor),
                  ),
                  style: ElevatedButton.styleFrom(
                    shadowColor: lightGrayColor,
                    iconColor: secondaryColor,
                  ),
                ),
                const SizedBox(height: 15),
                OutlineTextField(
                    textEditingController: _latitudeController, labelText: 'Latitude', readOnly: true),
                const SizedBox(height: 15),
                OutlineTextField(
                    textEditingController: _longitudeController, labelText: 'Longitude', readOnly: true),
                const SizedBox(height: 30),
                _isLoading
                    ? const CircularProgressIndicator() // Show loading spinner
                    : InkWell(
                  onTap: _savePetCare, // Call save function
                  child: Container(
                    width: double.infinity,
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: ShapeDecoration(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      color: secondaryColor,
                    ),
                    child: const Text(
                      'Save',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
