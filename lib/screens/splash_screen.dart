import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:lottie/lottie.dart';
import 'package:pet_buddy/screens/admin/dashboard.dart';
import 'package:pet_buddy/screens/doctor/d_dashboard.dart';
import 'package:pet_buddy/screens/login_page.dart';
import 'package:pet_buddy/utils/colors.dart';
import 'package:pet_buddy/widgets/nav_bar.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  String getLoginState() {
    var box = Hive.box('loginBox');
    return box.get('login_state', defaultValue: 'logged_out'); // Default to logged out
  }

  String getUserRole() {
    var box = Hive.box('loginBox');
    return box.get('user_role', defaultValue: 'user'); // Default to user
  }

  @override
  Widget build(BuildContext context) {
    String loginState = getLoginState();
    String userRole = getUserRole();

    Widget nextScreen;

    if (loginState == 'logged') {
      if (userRole == 'admin') {
        nextScreen = const AdminDashboard();
      } else if (userRole == 'doctor') {
        nextScreen = const DoctorDashboard();
      } else {
        nextScreen = const NavBar(); // Default to user role
      }
    } else {
      nextScreen = const LoginPage();
    }

    return AnimatedSplashScreen(
      splash: Column(
        children: [
          Center(
            child: LottieBuilder.asset(
              'assets/images/splash_animation.json',
              width: 250,
              height: 250,
            ),
          ),
          const Text(
            'Pet Buddy',
            style: TextStyle(
              fontFamily: 'CustomRegular',
              fontSize: 50,
              fontWeight: FontWeight.bold,
              color: darkGreen,
            ),
          ),
          const SizedBox(height: 30),
          LoadingAnimationWidget.inkDrop(color: darkGreen, size: 32),
        ],
      ),
      splashIconSize: 400,
      backgroundColor: secondaryColor,
      nextScreen: nextScreen,
    );
  }
}
