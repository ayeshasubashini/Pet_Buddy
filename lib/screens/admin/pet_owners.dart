import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pet_buddy/utils/colors.dart';

class PetOwners extends StatefulWidget {
  const PetOwners({super.key});

  @override
  State<PetOwners> createState() => _PetOwnersState();
}

class _PetOwnersState extends State<PetOwners> {
  // Fetch users from Firestore
  Stream<QuerySnapshot> _getUsers() {
    return FirebaseFirestore.instance
        .collection('userdetails')
        .where('role', isEqualTo: 'user')
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(scaffoldBackgroundColor: Colors.white),
      debugShowCheckedModeBanner: false,
      title: 'Pet Owners',
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: secondaryColor,
          leading: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: Colors.white,
            ),
          ),
          title: const Text(
            'Pet Owners',
            style: TextStyle(color: Colors.white),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: StreamBuilder<QuerySnapshot>(
            stream: _getUsers(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return const Center(child: Text('Error loading data.'));
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text('No users found.'));
              }

              final users = snapshot.data!.docs;

              return ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];
                  final name = user['name'] ?? 'Unknown';
                  final email = user['email'] ?? 'No email';
                  final profileImage = user['profile_image'] ??
                      'https://banner2.cleanpng.com/20180418/xqw/kisspng-avatar-computer-icons-business-business-woman-5ad736ba3f2735.7973320115240536902587.jpg'; // Default image

                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        radius: 30.0,
                        backgroundImage: NetworkImage(profileImage),
                      ),
                      title: Text(name),
                      subtitle: Text(email),
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
