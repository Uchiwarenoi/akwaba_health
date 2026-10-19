import 'package:flutter/material.dart';
import 'package:akwaba_health/pages/vaccins_page.dart';
import 'package:akwaba_health/pages/medicaments_page.dart';
import 'package:akwaba_health/pages/analyses_page.dart';
import 'package:akwaba_health/pages/dossiermedical_page.dart';
import 'package:akwaba_health/pages/rendezvous_page.dart';
import 'package:akwaba_health/pages/urgence_page.dart';

class ListeChoix extends StatelessWidget {
  const ListeChoix({super.key});

  Widget buildCard(
      BuildContext context, IconData icon, String title, Widget page) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => page),
        );
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon, 
                size: 40, 
                color:Color.fromARGB(255, 158, 221, 76)
                ),
              const SizedBox(height: 10),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 15,
          mainAxisSpacing: 15,
          children: [

            buildCard(context, Icons.folder_shared, "Dossier Médical",
              const DossierMedicalPage()),

            buildCard(context, Icons.science, "Analyses",
                const AnalysesPage()),  

            buildCard(context, Icons.medication, "Médicaments",
                const MedicamentsPage()),

            buildCard(context, Icons.vaccines, "Vaccins",
                const VaccinsPage()),
                
            buildCard(context, Icons.history, "Rendez-Vous",
                const RendezVousPage()),
            
            buildCard(context,Icons.warning, "Urgence",
                const UrgencePage()),    
          ],
        ),
      ),
    );
  }
}