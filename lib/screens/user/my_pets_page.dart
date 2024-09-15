import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:pet_buddy/screens/user/pet_create.dart';
import 'package:pet_buddy/screens/user/pet_update.dart'; // Import your PetUpdatePage here
import 'package:pet_buddy/utils/colors.dart';
import 'package:qr_flutter/qr_flutter.dart'; // Import QR code package

class MyPetsPage extends StatefulWidget {
  const MyPetsPage({Key? key}) : super(key: key);

  @override
  State<MyPetsPage> createState() => _MyPetsPageState();
}

class _MyPetsPageState extends State<MyPetsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? uid;
  String? _deathReason;
  String? _deathDate;
  Map<String, dynamic>? _petData;
  final TextEditingController deathController = TextEditingController();// Store pet data for updating

  @override
  void initState() {
    super.initState();
    _getUserId(); // Load user ID from Hive
  }

  // Method to retrieve the user ID from Hive
  Future<void> _getUserId() async {
    var hive = await Hive.openBox('loginBox');
    setState(() {
      uid = hive.get("uid");
    });
  }

  // Method to fetch pets from Firestore
  Stream<QuerySnapshot> _getPetsStream() {
    if (uid != null) {
      return _firestore
          .collection('pets')
          .where('user_ref', isEqualTo: uid)
          .snapshots();
    } else {
      return const Stream.empty();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Pets'),
        backgroundColor: secondaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PetCreate()),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _getPetsStream(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No pets found.'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var petDoc = snapshot.data!.docs[index];
              var petData = petDoc.data() as Map<String, dynamic>;

              return GestureDetector(
                onTap: () {
                  _showPetOptions(context, petDoc.id, petData); // Pass document ID
                },
                child: _buildPetCard(petData),
              );
            },
          );
        },
      ),
    );
  }

  // Method to build a pet card for displaying pet details
  Widget _buildPetCard(Map<String, dynamic> petData) {
    String name = petData['name'] ?? 'Unknown';
    String breed = petData['breed'] ?? 'Unknown';
    String age = petData['age'] ?? 'Unknown';
    String type = petData['type'] ?? 'Unknown';
    String? imageUrl = petData['image']; // Use the direct URL stored in Firestore

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // If the pet has an image, display it using the direct URL from Firestore
            if (imageUrl != null && imageUrl.isNotEmpty)
              _buildPetImage(imageUrl),
            const SizedBox(width: 15),
            // Display pet details
            _buildPetDetails(name, type, breed, age),
          ],
        ),
      ),
    );
  }

  // Method to build the pet image from the URL
  Widget _buildPetImage(String imageUrl) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image.network(
        imageUrl, // Directly use the image URL from Firestore
        height: 100,
        width: 100,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const SizedBox(
            height: 100,
            width: 100,
            child: Center(
              child: Icon(
                Icons.image_not_supported,
                size: 50,
                color: Colors.grey,
              ),
            ),
          );
        },
        loadingBuilder: (BuildContext context, Widget child,
            ImageChunkEvent? loadingProgress) {
          if (loadingProgress == null) {
            return child;
          }
          return SizedBox(
            height: 100,
            width: 100,
            child: Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                    (loadingProgress.expectedTotalBytes ?? 1)
                    : null,
              ),
            ),
          );
        },
      ),
    );
  }

  // Method to build pet details text
  Widget _buildPetDetails(String name, String type, String breed, String age) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          Text('Type: $type'),
          Text('Breed: $breed'),
          Text('Age: $age'),
        ],
      ),
    );
  }

  // Method to show bottom sheet with options
  void _showPetOptions(BuildContext context, String petId, Map<String, dynamic> petData) {
    _petData = petData; // Store pet data for use in the dialog
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('View/Edit'),
              onTap: () {
                _viewOrEditPet(petId, petData);
              },
            ),
            ListTile(
              leading: const Icon(Icons.qr_code),
              title: const Text('QR Code'),
              onTap: () {
                _showQrCodeDialog(petId); // Show QR code dialog
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('Remove'),
              onTap: () {
                _removePet(petId);
              },
            ),
            ListTile(
              leading: const Icon(Icons.pets),
              title: const Text('Mark as Dead'),
              onTap: () {
                _markAsDead(petId);
              },
            ),
          ],
        );
      },
    );
  }

  // Method to display the QR code dialog
  void _showQrCodeDialog(String petId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pet QR Code'),
          content: SizedBox(
            width: 250,
            height: 250,
            child: Center(
              child: QrImageView(
                data: petId, // Use petId as data for QR code
                version: QrVersions.auto,
                size: 200.0,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  // Function for viewing/editing a pet, now navigates to the update page
  void _viewOrEditPet(String petId, Map<String, dynamic> petData) {
    Navigator.pop(context); // Close the bottom sheet
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PetUpdate(petId: petId),
      ),
    );
  }

  // Function for removing a pet
  void _removePet(String petId) {
    Navigator.pop(context); // Close the bottom sheet
    _firestore.collection('pets').doc(petId).delete().then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pet removed successfully')),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to remove pet: $error')),
      );
    });
  }

  // Function for marking a pet as dead
  void _markAsDead(String petId) {
    Navigator.pop(context); // Close the bottom sheet
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Mark Pet as Deceased'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Death Reason',
                ),
                onChanged: (value) {
                  _deathReason = value; // Store the reason
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: deathController,
                decoration: const InputDecoration(
                  labelText: 'Death Date',
                  hintText: 'YYYY-MM-DD',
                ),
                readOnly: true, // Prevents the keyboard from appearing
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(1900), // Starting date
                    lastDate: DateTime.now(), // Today's date
                  );

                  if (pickedDate != null) {
                    // Format the selected date and assign it to the controller
                    String formattedDate = "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
                    deathController.text = formattedDate;
                    _deathDate = formattedDate; // Store the date
                  }
                },
              ),

            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (_deathReason != null && _deathDate != null) {
                  Navigator.pop(context); // Close the dialog
                  _updatePetStatus(petId); // Update status and move to 'dead_pets'
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please provide all details')),
                  );
                }
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  // Function for updating pet status and moving to 'dead_pets'
  void _updatePetStatus(String petId) {
    if (_petData != null) {
      // Add pet data to 'dead_pets' collection
      _firestore.collection('dead_pets').doc(petId).set({
        ..._petData!,
        'death_reason': _deathReason,
        'death_date': _deathDate,
      }).then((_) {
        // Remove pet from 'pets' collection
        _firestore.collection('pets').doc(petId).delete().then((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Pet marked as deceased')),
          );
        }).catchError((error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to remove pet: $error')),
          );
        });
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add pet to dead_pets: $error')),
        );
      });
    }
  }
}
