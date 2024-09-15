import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:pet_buddy/screens/login_page.dart';

import '../../utils/colors.dart';
import '../../widgets/nav_bar.dart';
import '../../widgets/text_field_input.dart';

class RegisterUser extends StatefulWidget {
  const RegisterUser({super.key});

  @override
  State<RegisterUser> createState() => _RegisterUserState();
}

class _RegisterUserState extends State<RegisterUser> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordConfirmController =
      TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final CollectionReference _userCollection =
      FirebaseFirestore.instance.collection("userdetails");

  void signUp() async {
    signupWithEmail(_emailController.text, _passwordController.text);
  }

  Future<void> signupWithEmail(String email, String password) async {
    var box = Hive.box('loginBox');

    if (_emailController.text.isEmpty ||
        _usernameController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _passwordConfirmController.text.isEmpty) {
      showAlertMessage("All fields are required", CoolAlertType.error);
    } else if (!RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(_emailController.text)) {
      showAlertMessage("Invalid email address", CoolAlertType.error);
    } else if (_passwordController.text != _passwordConfirmController.text) {
      showAlertMessage("Passwords doesn't matched.", CoolAlertType.error);
    } else {
      try {
        await _firebaseAuth.createUserWithEmailAndPassword(
            email: email, password: password);
        var user = await _userCollection.add({
          'email': _emailController.text,
          'user_name': _usernameController.text,
          'address': '',
          'contact': '',
          'profile_image': '',
          'name': _usernameController.text,
          'role': 'user',
        });

        box.put("uid", user.id);

        navigateToDashboard();
      } on FirebaseAuthException catch (e) {
        switch (e.code) {
          case 'weak-password':
            showAlertMessage(
                "The password provided is too weak.", CoolAlertType.error);
          case 'email-already-in-use':
            showAlertMessage("The account already exists for that email",
                CoolAlertType.error);
          case 'invalid-email':
            showAlertMessage(
                "The email address is not valid.", CoolAlertType.error);
          default:
            showAlertMessage(
                "Failed to sign up: ${e.message}", CoolAlertType.error);
        }
      } catch (e) {
        // Handle other potential exceptions
        throw Exception("An unknown error occurred: $e");
      }
    }
  }

  void navigateToDashboard() {
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const NavBar()));
  }

  void showAlertMessage(messageText, messageType) {
    CoolAlert.show(context: context, type: messageType, text: messageText);
  }

  @override
  Widget build(BuildContext context) {
    void navigateToSignIn() {
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginPage()));
    }

    return MaterialApp(
        theme: ThemeData(scaffoldBackgroundColor: Colors.white),
        debugShowCheckedModeBanner: false,
        title: 'Sign Up Page',
        home: Scaffold(
          body: SafeArea(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                  child: SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 120),
                      const Text(
                        'Sign Up',
                        style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: secondaryColor),
                      ),
                      const SizedBox(height: 25),
                      TextFieldInput(
                        textEditingController: _usernameController,
                        hintText: "Username",
                        textInputType: TextInputType.text,
                        icon: const Icon(
                          Icons.person,
                          color: secondaryColor,
                        ),
                      ),
                      const SizedBox(height: 15),
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
                      TextFieldInput(
                        textEditingController: _passwordConfirmController,
                        hintText: "Retype Password",
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
                          signUp();
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
                          child: const Text(
                            'Sign Up',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text('Already have account ?'),
                          TextButton(
                              onPressed: navigateToSignIn,
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
