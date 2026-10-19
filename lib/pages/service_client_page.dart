import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ServiceClientPage extends StatefulWidget {
  const ServiceClientPage({super.key});

  @override
  State<ServiceClientPage> createState() => _ServiceClientPageState();
}

class _ServiceClientPageState extends State<ServiceClientPage> {
  final TextEditingController messageController = TextEditingController();

  final String number1 = "+2250788579540";
  final String number2 = "+2250767226078";

  // ---------------- HEADER ----------------
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
            Icon(Icons.support_agent, color: Colors.white, size: 40),
            SizedBox(height: 10),
            Text(
              "Centre d’assistance",
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

  Future<void> call(String number) async {
    final uri = Uri.parse("tel:$number");
    await launchUrl(uri);
  }

  Future<void> whatsapp(String number, String message) async {
    final uri = Uri.parse(
      "https://wa.me/$number?text=${Uri.encodeComponent(message)}",
    );
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  void sendMessage() {
    if (messageController.text.trim().isEmpty) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Message envoyé au support ✅"),
      ),
    );

    messageController.clear();
  }

  Widget supportCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Icon(icon, color: color),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          buildHeader(),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  const Center(
                    child: Text(
                      "Support client Akwaba Health",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  supportCard(
                    icon: Icons.phone,
                    title: "Appeler support 1",
                    subtitle: number1,
                    color: Colors.green,
                    onTap: () => call(number1),
                  ),

                  supportCard(
                    icon: Icons.phone,
                    title: "Appeler support 2",
                    subtitle: number2,
                    color: Colors.green,
                    onTap: () => call(number2),
                  ),

                  supportCard(
                    icon: Icons.chat,
                    title: "WhatsApp support 1",
                    subtitle: "Réponse rapide",
                    color: Colors.green,
                    onTap: () => whatsapp(
                      number1,
                      "Bonjour, j'ai besoin d'aide avec AkwabaHealth",
                    ),
                  ),

                  supportCard(
                    icon: Icons.chat,
                    title: "WhatsApp support 2",
                    subtitle: "Réponse rapide",
                    color: Colors.green,
                    onTap: () => whatsapp(
                      number2,
                      "Bonjour, j'ai besoin d'aide avec AkwabaHealth",
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    "Envoyer un message rapide",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 10),

                  TextField(
                    controller: messageController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: "Décrivez votre problème...",
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 10),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 104, 243, 137),
                      ),
                      onPressed: sendMessage,
                      child: const Text("Envoyer au support",
                      style: TextStyle(color: Colors.white),),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}