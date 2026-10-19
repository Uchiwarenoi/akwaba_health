import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AnalysesPage extends StatefulWidget {
  const AnalysesPage({super.key});

  @override
  State<AnalysesPage> createState() => _AnalysesPageState();
}

class _AnalysesPageState extends State<AnalysesPage> {
  final uid = FirebaseAuth.instance.currentUser!.uid;

  final typeController = TextEditingController();
  final resultatController = TextEditingController();
  final laboratoireController = TextEditingController();
  final notesController = TextEditingController();

  String statut = "normal";

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
            Icon(Icons.science, color: Colors.white, size: 40),
            SizedBox(height: 10),
            Text(
              "Analyses",
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

  Future<void> ajouterAnalyse() async {
    if (typeController.text.trim().isEmpty ||
        resultatController.text.trim().isEmpty ||
        laboratoireController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("⚠️ Veuillez remplir les champs obligatoires"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('Analyses')
        .add({
      'type': typeController.text.trim(),
      'resultat': resultatController.text.trim(),
      'laboratoire': laboratoireController.text.trim(),
      'notes': notesController.text.trim(),
      'statut': statut,
      'date': Timestamp.now(),
    });

    typeController.clear();
    resultatController.clear();
    laboratoireController.clear();
    notesController.clear();

    setState(() {
      statut = "normal";
    });
  }

  Widget _buildStatutBadge(String statut) {
    Color color;
    String label;

    switch (statut) {
      case "critique":
        color = Colors.red;
        label = "CRITIQUE";
        break;
      case "suspect":
        color = Colors.orange;
        label = "SUSPECT";
        break;
      default:
        color = Colors.green;
        label = "NORMAL";
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [

          buildHeader(),

          const SizedBox(height: 15),

          Text("Champs obligatoire *",
          style: TextStyle(color: Colors.red),),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextField(
                    controller: typeController,
                    decoration: const InputDecoration(labelText: "Type *"),
                  ),
                  const SizedBox(height: 8),

                  TextField(
                    controller: resultatController,
                    decoration: const InputDecoration(labelText: "Résultat *"),
                  ),
                  const SizedBox(height: 8),

                  TextField(
                    controller: laboratoireController,
                    decoration: const InputDecoration(labelText: "Laboratoire *"),
                  ),
                  const SizedBox(height: 8),

                  TextField(
                    controller: notesController,
                    decoration: const InputDecoration(labelText: "Notes"),
                  ),

                  const SizedBox(height: 10),

                  DropdownButtonFormField<String>(
                    value: statut,
                    decoration: const InputDecoration(labelText: "Statut"),
                    items: const [
                      DropdownMenuItem(value: "normal", child: Text("Normal")),
                      DropdownMenuItem(value: "suspect", child: Text("Suspect")),
                      DropdownMenuItem(value: "critique", child: Text("Critique")),
                    ],
                    onChanged: (value) {
                      setState(() {
                        statut = value!;
                      });
                    },
                  ),

                  const SizedBox(height: 10),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6EEB83),
                      ),
                      onPressed: ajouterAnalyse,
                      child: const Text(
                        "Ajouter",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ---------------- LISTE ----------------
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .doc(uid)
                        .collection('Analyses')
                        .orderBy('date', descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      final docs = snapshot.data!.docs;

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: docs.length,
                        itemBuilder: (context, index) {
                          final doc = docs[index];
                          final data = doc.data() as Map<String, dynamic>;

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: Padding(
                              padding: const EdgeInsets.all(15),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // ---------------- TITRE + STATUT ----------------
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        data['type'] ?? '',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                      ),
                                      _buildStatutBadge(data['statut'] ?? 'normal'),
                                    ],
                                  ),

                                  const SizedBox(height: 8),

                                  Text(data['resultat'] ?? ''),
                                  Text("🏥 ${data['laboratoire'] ?? ''}"),

                                  if ((data['notes'] ?? '').toString().isNotEmpty)
                                    Text(
                                      "📝 ${data['notes']}",
                                      style: const TextStyle(
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                ],
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