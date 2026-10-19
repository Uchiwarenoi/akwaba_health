import 'package:flutter/material.dart';
import 'package:akwaba_health/pages/maladies_page.dart';
import 'package:akwaba_health/pages/antecedants_page.dart';
class DossierMedicalPage extends StatelessWidget {
  const DossierMedicalPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Dossier médical",
          style: TextStyle(color: Colors.white),),

          iconTheme: const IconThemeData(
            color: Colors.white,
          ),


          flexibleSpace: Container(
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
          ),

          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(text: "Maladies"),
              Tab(text: "Antécédants"),
            ],
          ),
        ),
                body: const TabBarView(
                  children: [
                    MaladiesTab(),
                    AntecedantsTab(),
                  ],
                ),
              ),
            );
          }
        }
