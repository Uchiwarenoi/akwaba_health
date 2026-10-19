import 'package:akwaba_health/pages/login_page.dart';
import 'package:akwaba_health/pages/acueill_normal_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SplashScreenPage extends StatefulWidget {
  const SplashScreenPage({super.key});

  @override
  State<SplashScreenPage> createState() => _SplashScreenPageState();
}

class _SplashScreenPageState extends State<SplashScreenPage> {

  @override
  void initState() {
    super.initState();
    checkUser();
  }

  Future<void> checkUser() async {
    await Future.delayed(const Duration(seconds: 5)); // effet splash

    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // 🔓 utilisateur connecté
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AccueilNormalPage()),
      );
    } else {
      // 🔐 utilisateur non connecté
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            Image.asset(
              "assets/images/Akwaba.jpeg",
              width: 300,
              height: 300,
            ),

            const Text(
              "Bienvenue sur Akwaba Health",
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            const Text(
              "Votre santé toujours à portée de main.",
              style: TextStyle(
                fontSize: 16,
                color: Colors.black,
              ),
            ),

            const SizedBox(height: 30),

            const CircularProgressIndicator(
              color: Color.fromARGB(255, 20, 160, 2),
            ),
          ],
        ),
      ),
    );
  }
}