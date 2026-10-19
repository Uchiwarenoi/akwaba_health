import 'package:flutter/material.dart';
import 'package:akwaba_health/pages/urgence_invite.dart';

class ListeChoix extends StatelessWidget {
  const ListeChoix({super.key});

  void afficherMessage(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Row(
            children: [
              Icon(
                Icons.lock_outline,
                color: Colors.green,
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  "Accès restreint",
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
          content: const Text(
            "Veuillez vous connecter pour utiliser toutes les fonctionnalités de l'application.",
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text(
                "OK",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget buildCard(
    BuildContext context,
    IconData icon,
    String title, {
    Widget? page,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () {
        if (page != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => page,
            ),
          );
        } else {
          afficherMessage(context);
        }
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 40,
                color: Colors.green,
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
              const SizedBox(height: 8),
              Icon(
                page != null ? Icons.arrow_forward : Icons.lock,
                size: 18,
                color: Colors.grey,
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
            buildCard(
              context,
              Icons.folder_shared,
              "Dossier Médical",
            ),
            buildCard(
              context,
              Icons.science,
              "Analyses",
            ),
            buildCard(
              context,
              Icons.medication,
              "Médicaments",
            ),
            buildCard(
              context,
              Icons.vaccines,
              "Vaccins",
            ),
            buildCard(
              context,
              Icons.history,
              "Rendez-Vous",
            ),

            // Seule carte accessible sans connexion
            buildCard(
              context,
              Icons.warning,
              "Urgence",
              page: const UrgencePage(),
            ),
          ],
        ),
      ),
    );
  }
}