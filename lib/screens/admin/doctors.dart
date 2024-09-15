import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pet_buddy/screens/admin/doctor_create.dart';
import 'package:pet_buddy/screens/admin/doctor_profile.dart';
import 'package:pet_buddy/utils/colors.dart';

class Doctors extends StatefulWidget {
  const Doctors({super.key});

  @override
  State<Doctors> createState() => _DoctorsState();
}

class _DoctorsState extends State<Doctors> {
  void navigateToDoctorProfile(String doctorId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => DoctorProfile(doctorId: doctorId),
      ),
    );
  }

  void navigateToDoctorCreate() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => const DoctorCreate()));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(scaffoldBackgroundColor: Colors.white),
      debugShowCheckedModeBanner: false,
      title: 'Doctors',
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
            'Doctors',
            style: TextStyle(color: Colors.white),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              onPressed: navigateToDoctorCreate,
              icon: const Icon(
                Icons.person_add_alt_1,
                size: 32,
              ),
              color: darkGreen,
            )
          ],
        ),
        body: SafeArea(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('doctors')
                .where('role', isEqualTo: 'doctor')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text('No doctors available.'));
              }

              final doctors = snapshot.data!.docs;

              return ListView.builder(
                itemCount: doctors.length,
                itemBuilder: (context, index) {
                  final doctor = doctors[index].data() as Map<String, dynamic>;
                  final doctorId = doctors[index].id;  // This is the Firebase UID

                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        radius: 30.0,
                        backgroundImage: NetworkImage(
                          doctor['image_url'] ?? 'https://example.com/default_avatar.jpg',
                        ),
                      ),
                      title: Text(doctor['name'] ?? 'No Name'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(doctor['email'] ?? 'No Email'),
                          Text(doctor['contact'] ?? 'No Contact'),
                        ],
                      ),
                      onTap: () => navigateToDoctorProfile(doctorId),  // Pass UID to DoctorProfile
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
