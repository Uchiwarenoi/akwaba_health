import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RendezVousPage extends StatefulWidget {
  const RendezVousPage({super.key});

  @override
  State<RendezVousPage> createState() => _RendezVousPageState();
}

class _RendezVousPageState extends State<RendezVousPage> {
  final titreController = TextEditingController();
  final medecinController = TextEditingController();
  final lieuController = TextEditingController();
  final notesController = TextEditingController();

  DateTime? dateSelectionnee;

  final uid = FirebaseAuth.instance.currentUser!.uid;

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
            Icon(Icons.calendar_month, color: Colors.white, size: 40),
            SizedBox(height: 10),
            Text(
              "Rendez-vous",
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

  // ---------------- DATE ----------------
  Future<void> choisirDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() => dateSelectionnee = picked);
    }
  }

  // ---------------- AJOUT ----------------
  Future<void> ajouterRendezVous() async {
    if (titreController.text.trim().isEmpty || dateSelectionnee == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Titre et date obligatoires"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('RendezVous')
        .add({
      'titre': titreController.text.trim(),
      'medecin': medecinController.text.trim(),
      'lieu': lieuController.text.trim(),
      'notes': notesController.text.trim(),
      'date': Timestamp.fromDate(dateSelectionnee!),
      'createdAt': Timestamp.now(),
    });

    titreController.clear();
    medecinController.clear();
    lieuController.clear();
    notesController.clear();

    setState(() => dateSelectionnee = null);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Rendez-vous ajouté ✅"),
        backgroundColor: Colors.green,
      ),
    );
  }

  // ---------------- BUILD ----------------
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
                children: [

                  // ---------------- FORM ----------------
                  TextField(
                    controller: titreController,
                    decoration: const InputDecoration(
                      labelText: "Titre *",
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 10),

                  TextField(
                    controller: medecinController,
                    decoration: const InputDecoration(
                      labelText: "Médecin",
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 10),

                  TextField(
                    controller: lieuController,
                    decoration: const InputDecoration(
                      labelText: "centre de santé",
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 10),

                  TextField(
                    controller: notesController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: "Notes",
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 10),

                  ElevatedButton(
                    onPressed: choisirDate,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6EEB83),
                    ),
                    child: Text(
                      dateSelectionnee == null
                          ? "Choisir une date *"
                          : "${dateSelectionnee!.day}/${dateSelectionnee!.month}/${dateSelectionnee!.year}",
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),

                  const SizedBox(height: 10),

                  ElevatedButton(
                    onPressed: ajouterRendezVous,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6EEB83),
                    ),
                    child: const Text(
                      "Ajouter",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Historique",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // ---------------- LISTE ----------------
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .doc(uid)
                        .collection('RendezVous')
                        .orderBy('createdAt', descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const CircularProgressIndicator();
                      }

                      final docs = snapshot.data!.docs;

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: docs.length,
                        itemBuilder: (context, index) {
                          final data =
                              docs[index].data() as Map<String, dynamic>;

                          final date = data['date'] != null
                              ? (data['date'] as Timestamp)
                                  .toDate()
                                  .toString()
                                  .substring(0, 10)
                              : "";

                          return Card(
                            child: ListTile(
                              title: Text(data['titre'] ?? ""),
                              subtitle: Text(
                                "${data['medecin']} • $date",
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete,
                                    color: Colors.red),
                                onPressed: () {
                                  docs[index].reference.delete();
                                },
                              ),
                            ),
                          );
                        },
                      );
                    },
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