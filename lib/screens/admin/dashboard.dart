import 'package:flutter/material.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/bi.dart';
import 'package:iconify_flutter/icons/fontisto.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:pet_buddy/screens/admin/doctors.dart';
import 'package:pet_buddy/screens/admin/pet_cares.dart';
import 'package:pet_buddy/screens/admin/pet_owners.dart';
import 'package:pet_buddy/screens/profile_page.dart';
import 'package:pet_buddy/utils/colors.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  String? userRef;

  @override
  void initState() {
    super.initState();
    var box = Hive.box('loginBox');
    userRef = box.get('uid');
  }

  void navigateToPetOwner() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => const PetOwners()));
  }

  void navigateToDoctor() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => const Doctors()));
  }

  void navigateToPetCares() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => const PetCares()));
  }

  void navigateToProfile() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => const ProfilePage()));
  }

  @override
  Widget build(BuildContext context) {
    if (userRef == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: darkGreen,
          ),
        ),
      );
    }

    return MaterialApp(
      theme: ThemeData(scaffoldBackgroundColor: Colors.white),
      debugShowCheckedModeBanner: false,
      title: 'AdminDashboard',
      home: Scaffold(
        body: SafeArea(
          child: StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('userdetails')
                .doc(userRef)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: darkGreen,
                  ),
                );
              }

              var userdata = snapshot.data!.data() as Map<String, dynamic>;
              String userName = userdata['user_name'];
              String? profileImage = userdata['profile_image'];

              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.fromLTRB(0, 20, 10, 0),
                      child: Row(
                        children: [
                          const Spacer(),
                          InkWell(
                            onTap: navigateToProfile,
                            child: CircleAvatar(
                              radius: 30.0,
                              backgroundImage: profileImage != null
                                  ? NetworkImage(profileImage)
                                  : const NetworkImage(
                                  'https://banner2.cleanpng.com/20180418/xqw/kisspng-avatar-computer-'
                                      'icons-business-business-woman-5ad736ba3f2735.7973320115240536902587.jpg'),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text(
                                'Hello ',
                                style: TextStyle(fontSize: 20),
                              ),
                              Text(
                                userName,
                                style: const TextStyle(fontSize: 20),
                              ),
                            ],
                          ),
                          const Text(
                            "Welcome Back",
                            style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: secondaryColor),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: navigateToPetOwner,
                            child: Container(
                              margin: const EdgeInsets.all(10),
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: darkGreen,
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(20)),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    spreadRadius: 2,
                                    blurRadius: 2,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: const Column(
                                children: [
                                  Iconify(Bi.people_fill,
                                      size: 40, color: secondaryColor),
                                  SizedBox(height: 15),
                                  Text(
                                    'Pet Owners',
                                    style: TextStyle(
                                        fontSize: 20, color: secondaryColor),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: navigateToDoctor,
                            child: Container(
                              margin: const EdgeInsets.all(10),
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: darkGreen,
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(20)),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    spreadRadius: 2,
                                    blurRadius: 2,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: const Column(
                                children: [
                                  Iconify(Fontisto.doctor,
                                      size: 40, color: secondaryColor),
                                  SizedBox(height: 15),
                                  Text(
                                    'Doctors',
                                    style: TextStyle(
                                        fontSize: 20, color: secondaryColor),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: navigateToPetCares,
                            child: Container(
                              margin: const EdgeInsets.all(10),
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: darkGreen,
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(20)),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    spreadRadius: 2,
                                    blurRadius: 2,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: const Column(
                                children: [
                                  Iconify(Bi.house_heart_fill,
                                      size: 40, color: secondaryColor),
                                  SizedBox(height: 15),
                                  Text(
                                    'Pet Cares',
                                    style: TextStyle(
                                        fontSize: 20, color: secondaryColor),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
