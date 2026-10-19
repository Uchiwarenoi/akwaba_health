import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:akwaba_health/pages/login_page.dart';
import 'package:akwaba_health/pages/a_propos_page.dart';

class SettingsInvitPage extends StatefulWidget {
  const SettingsInvitPage({super.key});

  @override
  State<SettingsInvitPage> createState() => _SettingsInvitPageState();
}

class _SettingsInvitPageState extends State<SettingsInvitPage> {
  User? get user => FirebaseAuth.instance.currentUser;

  
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Pour b\u00E9n\u00E9ficier des fonctionnalit\u00E9s, connectez-vous.",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginPage()),
                      );
                    },
                    child: const Text("Se connecter", style: TextStyle(color: Colors.black)),
                  ),
                ],
              ),
            ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text("\u00C0 propos"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AboutPage()),
              );
            },
          ),
        ],
      ),
    );
  }
}
