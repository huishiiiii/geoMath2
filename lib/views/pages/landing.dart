import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geomath/views/pages/home.dart';

import 'login.dart';
import '../../helpers/asset_helper.dart';
import '../../helpers/color_constant.dart';
import '../../helpers/text_constant.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  @override
  void initState() {
    super.initState();
    // Check login status and navigate after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      checkLoginStatus();
    });
  }

  Future<void> checkLoginStatus() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    if (auth.currentUser != null) {
      // User is already logged in, navigate to home page or main app screen
      Navigator.of(context).pushReplacement(_createHomeRoute());
    } else {
      // User is not logged in, navigate to login page
      Navigator.of(context).pushReplacement(_createLoginRoute());
    }
  }

  Route _createLoginRoute() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>
          const LoginPage(),
      transitionDuration: const Duration(milliseconds: 700),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
    );
  }

  Route _createHomeRoute() {
    // Replace with your home page route
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => const HomePage(),
      transitionDuration: const Duration(milliseconds: 700),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Container(
            decoration: const BoxDecoration(color: ColorConstant.primaryColor),
          ),
          Center(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Image(
                  image: AssetImage(
                    AssetHelper.transparentLogo500,
                  ),
                  width: 130,
                  height: 130),
              Text(
                TextConstant.geomath.toUpperCase(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          )),
        ],
      ),
    );
  }
}
