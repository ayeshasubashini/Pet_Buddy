import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:pet_buddy/screens/admin/dashboard.dart';
import 'package:pet_buddy/screens/doctor/d_dashboard.dart';
import 'package:pet_buddy/screens/register_user.dart';
import 'package:pet_buddy/widgets/nav_bar.dart';
import 'package:pet_buddy/utils/colors.dart';
import '../widgets/text_field_input.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  bool _isLoading = false; // Loading state

  void login() {
    setState(() {
      _isLoading = true; // Start loading when login button is pressed
    });
    loginUser(_emailController.text, _passwordController.text);
  }

  Future<void> loginUser(String email, String password) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);

      // Check the userdetails collection
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection("userdetails")
          .where("email", isEqualTo: email)
          .get();

      String role;
      String uid;

      // If user is found in userdetails
      if (querySnapshot.docs.isNotEmpty) {
        role = querySnapshot.docs.first.get('role');
        uid = querySnapshot.docs.first.id;
      }
      // If not found, check the doctors collection
      else {
        querySnapshot = await FirebaseFirestore.instance
            .collection("doctors")
            .where("email", isEqualTo: email)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          role = 'doctor';
          uid = querySnapshot.docs.first.id;
        } else {
          setState(() {
            _isLoading = false;
          });
          showAlertMessage("No user found for that email.", CoolAlertType.error);
          return;
        }
      }

      var box = Hive.box('loginBox');
      box.put('email', email);
      box.put('password', password);
      box.put('login_state', 'logged');
      box.put('user_role', role);
      box.put('uid', uid);

      setState(() {
        _isLoading = false; // Stop loading after successful login
      });

      // Navigate based on role
      if (role == "user") {
        navigateToNavBar();
      } else if (role == "admin") {
        navigateToAdminPannel();
      } else if (role == "doctor") {
        navigateToDoctorPannel();
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _isLoading = false;
      });
      switch (e.code) {
        case 'user-not-found':
          showAlertMessage(
              "No user found for that email.", CoolAlertType.error);
          break;
        case 'wrong-password':
          showAlertMessage("Wrong password provided.", CoolAlertType.error);
          break;
        case 'invalid-email':
          showAlertMessage(
              "The email address is not valid.", CoolAlertType.error);
          break;
        default:
          showAlertMessage(
              "Failed to sign in: ${e.message}", CoolAlertType.error);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      throw Exception("Error occurred $e");
    }
  }


  void navigateToNavBar() {
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const NavBar()));
  }

  void navigateToSignUp() {
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const RegisterUser()));
  }

  void navigateToDoctorPannel() {
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const DoctorDashboard()));
  }

  void navigateToAdminPannel() {
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const AdminDashboard()));
  }

  void showAlertMessage(messageText, messageType) {
    CoolAlert.show(context: context, type: messageType, text: messageText);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData(scaffoldBackgroundColor: Colors.white),
        debugShowCheckedModeBanner: false,
        title: 'Login Page',
        home: Scaffold(
          body: SafeArea(
              child: Column(
                children: [
                  Expanded(
                      child: SingleChildScrollView(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          width: double.infinity,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const SizedBox(height: 80),
                              Image.asset(
                                'assets/images/login_image_green.png',
                                width: 150,
                                height: 150,
                                fit: BoxFit.cover,
                              ),
                              const SizedBox(height: 15),
                              const Text(
                                'Log In',
                                style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: secondaryColor),
                              ),
                              const SizedBox(height: 25),
                              TextFieldInput(
                                textEditingController: _emailController,
                                hintText: "Email",
                                textInputType: TextInputType.text,
                                icon: const Icon(
                                  Icons.email,
                                  color: secondaryColor,
                                ),
                              ),
                              const SizedBox(height: 15),
                              TextFieldInput(
                                textEditingController: _passwordController,
                                hintText: "Password",
                                textInputType: TextInputType.text,
                                icon: const Icon(
                                  Icons.lock,
                                  color: secondaryColor,
                                ),
                                isPass: true,
                              ),
                              const SizedBox(height: 15),
                              InkWell(
                                onTap: () {
                                  login();
                                },
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
                                  child: _isLoading
                                      ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                      : const Text(
                                    'Sign In',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Text("Don't you have an account?"),
                                  TextButton(
                                      onPressed: navigateToSignUp,
                                      child: const Text(
                                        'Sign Up',
                                        style: TextStyle(color: secondaryColor),
                                      ))
                                ],
                              )
                            ],
                          ),
                        ),
                      ))
                ],
              )),
        ));
  }
}
