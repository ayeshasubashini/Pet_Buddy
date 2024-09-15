import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ic.dart';
import 'package:iconify_flutter/icons/mdi.dart';
import 'package:pet_buddy/screens/admin/doctor_profile.dart';
import 'package:pet_buddy/screens/doctor/doctor_report.dart';
import 'package:pet_buddy/screens/doctor/qr_scanner.dart';
import 'package:pet_buddy/screens/login_page.dart';
import 'package:pet_buddy/utils/colors.dart';

class DoctorDashboard extends StatefulWidget {
  const DoctorDashboard({super.key});

  @override
  State<DoctorDashboard> createState() => _DoctorDashboardState();
}

class _DoctorDashboardState extends State<DoctorDashboard> {
  final FirebaseAuth auth = FirebaseAuth.instance;

  void navigateToQR() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => const QrScanner()));
  }

  void navigateToDReport() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => const DoctorReport()));
  }

  void navigateToProfile() {
    User? user = auth.currentUser; // Get current user
    if (user != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => DoctorProfile(doctorId: user.uid), // Pass the current user's ID
        ),
      );
    } else {
      // Handle the case where the user is not logged in (optional)
      print('No user is currently signed in.');
    }
  }

  void menuView(){
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        MediaQuery.of(context).size.width - 50,
        60,
        0,
        0,
      ),
      items: [
        PopupMenuItem(
          child: ListTile(
            leading: Icon(Icons.person, color: secondaryColor),
            title: Text('Profile',style: TextStyle(color: secondaryColor),),
            onTap: () {
              Navigator.of(context).pop(); // Close the menu
              navigateToProfile();
            },
          ),
        ),
        PopupMenuItem(
          child: ListTile(
            leading: Icon(Icons.exit_to_app, color: secondaryColor),
            title: Text('Logout',style: TextStyle(color: secondaryColor)),
            onTap: logout,
          ),
        ),
      ],
      elevation: 8.0,
    );

  }

  void logout() {
    saveLoggingData();
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginPage()));
  }

  void saveLoggingData() async {
    var box = await Hive.openBox('loginBox');
    box.put('login_state', 'logged_out');
  }

  @override
  Widget build(BuildContext context) {
    // Get the current user ID
    User? user = auth.currentUser;

    if (user == null) {
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
      title: 'DoctorDashboard',
      home: Scaffold(
        body: SafeArea(
          child: StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('doctors')
                .doc(user.uid)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: darkGreen,
                  ),
                );
              }

              var userDoc = snapshot.data!;
              var doctorName = userDoc['name'] ?? 'Doctor';

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
                            onTap: menuView,
                            child: Icon(Icons.menu,size: 40,)
                          )
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
                                doctorName, // Use the loaded doctor's name
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
                            onTap: navigateToQR,
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
                                  Iconify(
                                    Ic.baseline_qr_code_scanner,
                                    size: 40,
                                    color: secondaryColor,
                                  ),
                                  SizedBox(
                                    height: 15,
                                  ),
                                  Text(
                                    'QR Scanner',
                                    style: TextStyle(
                                        fontSize: 20, color: secondaryColor),
                                  )
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
                            onTap: navigateToDReport,
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
                                  Iconify(
                                    Mdi.papers,
                                    size: 40,
                                    color: secondaryColor,
                                  ),
                                  SizedBox(
                                    height: 15,
                                  ),
                                  Text(
                                    'Reports',
                                    style: TextStyle(
                                        fontSize: 20, color: secondaryColor),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
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
