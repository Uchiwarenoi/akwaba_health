import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  Widget buildHeader() {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(40),
        bottomRight: Radius.circular(40),
      ),
      child: Container(
        height: 180,
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(20, 40, 20, 20),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF6EEB83),
              Color.fromARGB(255, 243, 190, 94),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.info, color: Colors.white, size: 40),
            SizedBox(height: 10),
            Text(
              "À propos",
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          buildHeader(),

          const Expanded(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: SingleChildScrollView(
                child: Text(
                  "Akwaba Health\n\n"
                  "Votre carnet de santé virtuel pour vous accompagner au quotidien.\n\n"
                  "Développée par Alladaye Christian, Coulibaly Melvine et Oulaye Evariste étudiants en L1 Computer Science à l'Institut Ivoirien de Technologie (IIT).\n\n"
                  "Version 1.0.0",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}