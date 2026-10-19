import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class UrgencePage extends StatelessWidget {
  const UrgencePage({super.key});

  Future<void> appelerNumero(String numero) async {
    final uri = Uri(
      scheme: 'tel',
      path: numero,
    );

    await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        title: const Text(
          "Urgence",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 20),

            const Icon(
              Icons.warning_amber_rounded,
              color: Colors.red,
              size: 80,
            ),

            const SizedBox(height: 20),

            const Text(
              "Numéros d'urgence",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                icon: const Icon(
                  Icons.local_hospital,
                  color: Colors.white,
                ),
                label: const Text(
                  "SAMU - 185",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                onPressed: () => appelerNumero("185"),
              ),
            ),

            const SizedBox(height: 15),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                icon: const Icon(
                  Icons.local_fire_department,
                  color: Colors.white,
                ),
                label: const Text(
                  "POMPIERS - 180",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                onPressed: () => appelerNumero("180"),
              ),
            ),

            const SizedBox(height: 15),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                icon: const Icon(
                  Icons.local_police,
                  color: Colors.white,
                ),
                label: const Text(
                  "POLICE - 111",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                onPressed: () => appelerNumero("111"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}