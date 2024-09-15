import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pet_buddy/screens/admin/pet_cares_create.dart';
import 'package:pet_buddy/utils/colors.dart';

class PetCares extends StatefulWidget {
  const PetCares({super.key});

  @override
  State<PetCares> createState() => _PetCaresState();
}

class _PetCaresState extends State<PetCares> {
  // Function to navigate to Pet Care Create page
  void navigateToPetCareCreate() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => const PetCaresCreate()));
  }

  // Fetch pet care data as a stream from Firestore
  Stream<QuerySnapshot> _fetchPetCares() {
    return FirebaseFirestore.instance.collection('petCares').snapshots();
  }

  // Function to show a confirmation dialog before deleting a record
  Future<void> _showDeleteConfirmationDialog(String petId) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // Prevent dismissing by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Record'),
          content: const Text('Are you sure you want to delete this pet care record?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () {
                _removePet(petId); // Call the delete function
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }

  // Function to remove a pet record
  void _removePet(String petId) async {
    try {
      await FirebaseFirestore.instance.collection('petCares').doc(petId).delete();
      print('Pet record deleted: $petId');
    } catch (e) {
      print('Error deleting pet record: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(scaffoldBackgroundColor: Colors.white),
      debugShowCheckedModeBanner: false,
      title: 'Pet Cares',
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
            'Pet Cares',
            style: TextStyle(color: Colors.white),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              onPressed: navigateToPetCareCreate,
              icon: const Icon(
                Icons.add_home_rounded,
                size: 32,
              ),
              color: darkGreen,
            )
          ],
        ),
        body: SafeArea(
          child: StreamBuilder<QuerySnapshot>(
            stream: _fetchPetCares(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator()); // Show loading spinner
              }

              if (snapshot.hasError) {
                return const Center(child: Text('Error fetching data')); // Show error message
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text('No pet care entries available')); // No data message
              }

              // Fetch documents from the snapshot
              final List<DocumentSnapshot> documents = snapshot.data!.docs;

              return ListView.builder(
                padding: const EdgeInsets.all(5),
                itemCount: documents.length,
                itemBuilder: (context, index) {
                  // Get pet care data from each document
                  final petCare = documents[index].data() as Map<String, dynamic>;
                  final petId = documents[index].id;  // Get the document ID
                  final name = petCare['name'] ?? 'No Name';
                  final address = petCare['address'] ?? 'No Address';

                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.home),
                      title: Text(name),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(address),
                        ],
                      ),
                      onTap: () {
                        _showDeleteConfirmationDialog(petId);
                      },
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
