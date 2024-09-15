import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:pet_buddy/screens/splash_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> checkAndCreateAdmin() async {
  // Reference to Firestore collection
  CollectionReference users = FirebaseFirestore.instance.collection('userdetails');

  // Query to check if any admin user exists
  QuerySnapshot querySnapshot = await users.where('role', isEqualTo: 'admin').get();

  // If no admin exists, create a new admin
  if (querySnapshot.docs.isEmpty) {
    try {
      // Create a new Firebase Auth user (if needed)
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: "admin@gmail.com",  // Replace with the desired admin email
        password: "admin1234",  // Replace with the desired password
      );

      // Add user details to Firestore
      await users.doc(userCredential.user?.uid).set({
        'name': 'Admin',
        'user_name': 'Admin',
        'email': 'admin@gmail.com',
        'role': 'admin',
        'profile_image': '',
        // Add any other admin fields you want
      });

      print('Admin user created successfully');
    } catch (e) {
      print('Error creating admin user: $e');
    }
  } else {
    print('Admin user already exists');
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('loginBox');
  await Firebase.initializeApp();

  // Call the checkAndCreateAdmin function
  await checkAndCreateAdmin();  // Ensure this is awaited

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  String getLoginState() {
    var box = Hive.box('loginBox');
    String loginState = box.get('login_state', defaultValue: 'logged_out'); // Provide a default value
    return loginState;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}
