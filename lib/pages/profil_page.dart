import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfilPage extends StatefulWidget {
  const ProfilPage({super.key});

  @override
  State<ProfilPage> createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  final user = FirebaseAuth.instance.currentUser!;

  // ---------------- IMC ----------------
  double imc(String p, String t) {
    try {
      final poids = double.parse(p);
      final taille = double.parse(t) / 100;
      if (taille == 0) return 0;
      return poids / (taille * taille);
    } catch (_) {
      return 0;
    }
  }

  String categorieIMC(double imc) {
    if (imc <= 0) return "";
    if (imc < 18.5) return "Maigreur";
    if (imc < 25) return "Normal";
    if (imc < 30) return "Surpoids";
    if (imc < 35) return "Obésité modérée";
    return "Obésité sévère";
  }

  Color couleurIMC(double imc) {
    if (imc < 18.5) return Colors.blue;
    if (imc < 25) return Colors.green;
    if (imc < 30) return Colors.orange;
    return Colors.red;
  }

  // ---------------- EDIT PROFIL ----------------
  void editProfile(BuildContext context, Map<String, dynamic> data) {
    final nom = TextEditingController(text: data['nom'] ?? '');
    final prenom = TextEditingController(text: data['prenom'] ?? '');
    final age = TextEditingController(text: data['age'] ?? '');
    final poids = TextEditingController(text: data['poids'] ?? '');
    final taille = TextEditingController(text: data['taille'] ?? '');

    final groupes = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];
    String selected = data['groupe_sanguin'] ?? 'A+';

    showDialog(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text("Modifier profil"),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    TextField(controller: nom, decoration: const InputDecoration(labelText: "Nom")),
                    TextField(controller: prenom, decoration: const InputDecoration(labelText: "Prénom")),
                    TextField(controller: age, decoration: const InputDecoration(labelText: "Âge")),
                    TextField(controller: poids, decoration: const InputDecoration(labelText: "Poids (kg)")),
                    TextField(controller: taille, decoration: const InputDecoration(labelText: "Taille (cm)")),

                    const SizedBox(height: 10),

                    DropdownButtonFormField(
                      value: selected,
                      items: groupes.map((g) {
                        return DropdownMenuItem(
                          value: g,
                          child: Text(g),
                        );
                      }).toList(),
                      onChanged: (v) {
                        setStateDialog(() {
                          selected = v!;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Annuler"),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1FAF5A),
                  ),
                  onPressed: () async {
                    await FirebaseFirestore.instance
                        .collection("users")
                        .doc(user.uid)
                        .set({
                      "nom": nom.text,
                      "prenom": prenom.text,
                      "age": age.text,
                      "poids": poids.text,
                      "taille": taille.text,
                      "groupe_sanguin": selected,
                    }, SetOptions(merge: true));

                    Navigator.pop(context);
                  },
                  child: const Text("Enregistrer"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ---------------- HEADER ----------------
  Widget buildHeader(String prenom, String nom) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(40),
        bottomRight: Radius.circular(40),
      ),
      child: Container(
        height: 220,
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 35,
              backgroundColor: Colors.white24,
              child: Icon(Icons.person, size: 48, color: Colors.white),
            ),
            const SizedBox(height: 10),
            Text(
              "$prenom $nom",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              "Profil utilisateur",
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- CARD ----------------
  Widget card(String title, String value) {
    return Card(
      child: ListTile(
        title: Text(title),
        subtitle: Text(value.isEmpty ? "Non renseigné" : value),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection("users")
            .doc(user.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;

          final imcValue = imc(
            data['poids'] ?? '0',
            data['taille'] ?? '0',
          );

          return Column(
            children: [
              buildHeader(
                data['prenom'] ?? '',
                data['nom'] ?? '',
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [

                      card("Nom", data['nom'] ?? ''),
                      card("Prénom", data['prenom'] ?? ''),
                      card("Âge", data['age'] ?? ''),
                      card("Poids (kg)", data['poids'] ?? ''),
                      card("Taille (cm)", data['taille'] ?? ''),
                      card("Groupe sanguin", data['groupe_sanguin'] ?? ''),

                      if (imcValue > 0)
                        Card(
                          child: ListTile(
                            title: const Text("IMC"),
                            subtitle: Text(
                              "${imcValue.toStringAsFixed(1)} - ${categorieIMC(imcValue)}",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: couleurIMC(imcValue),
                              ),
                            ),
                          ),
                        ),

                      const SizedBox(height: 20),

                      ElevatedButton.icon(
                        onPressed: () => editProfile(context, data),
                        icon: const Icon(Icons.edit, color: Colors.white),
                        label: const Text(
                          "Modifier profil",
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:  Color(0xFF6EEB83),
                          minimumSize: const Size(double.infinity, 50),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}