import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class VaccinsPage extends StatefulWidget {
  const VaccinsPage({super.key});

  @override
  State<VaccinsPage> createState() => _VaccinsPageState();
}

class _VaccinsPageState extends State<VaccinsPage> {
  final nomController = TextEditingController();
  final centreController = TextEditingController();
  final notesController = TextEditingController();

  DateTime? selectedDate;
  DateTime? rappelDate;

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
            Icon(Icons.vaccines, color: Colors.white, size: 40),
            SizedBox(height: 10),
            Text(
              "Vaccins",
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

  Future<void> pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() => selectedDate = picked);
    }
  }

  Future<void> pickRappelDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() => rappelDate = picked);
    }
  }

  Future<void> ajouterVaccin() async {
    final nom = nomController.text.trim();
    final centre = centreController.text.trim();

    if (nom.isEmpty || centre.isEmpty || selectedDate == null) {
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
        .collection('Vaccins')
        .add({
      'nom': nom,
      'centre': centre,
      'date':
          "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",
      'notes': notesController.text.trim(),
      'rappel': rappelDate == null
          ? ""
          : "${rappelDate!.day}/${rappelDate!.month}/${rappelDate!.year}",
      'createdAt': Timestamp.now(),
    });

    nomController.clear();
    centreController.clear();
    notesController.clear();

    setState(() {
      selectedDate = null;
      rappelDate = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("💉 Vaccin ajouté avec succès"),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // ---------------- HEADER ----------------
          buildHeader(),

          // ---------------- CONTENT ----------------
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Champs obligatoires *",
                      style: TextStyle(color: Colors.red),
                    ),
                  ),

                  const SizedBox(height: 10),

                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          TextField(
                            controller: nomController,
                            decoration: const InputDecoration(
                              labelText: "Nom du vaccin *",
                            ),
                          ),

                          const SizedBox(height: 10),

                          TextField(
                            controller: centreController,
                            decoration: const InputDecoration(
                              labelText: "Centre *",
                            ),
                          ),

                          const SizedBox(height: 10),

                          ListTile(
                            leading: const Icon(Icons.calendar_today),
                            title: Text(
                              selectedDate == null
                                  ? "Date du vaccin *"
                                  : "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",
                            ),
                            onTap: pickDate,
                          ),

                          ListTile(
                            leading: const Icon(Icons.alarm),
                            title: Text(
                              rappelDate == null
                                  ? "Rappel (optionnel)"
                                  : "${rappelDate!.day}/${rappelDate!.month}/${rappelDate!.year}",
                            ),
                            onTap: pickRappelDate,
                          ),

                          TextField(
                            controller: notesController,
                            maxLines: 3,
                            decoration: const InputDecoration(
                              labelText: "Notes",
                            ),
                          ),

                          const SizedBox(height: 15),

                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: ajouterVaccin,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF6EEB83),
                              ),
                              child: const Text(
                                "Ajouter",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .doc(uid)
                        .collection('Vaccins')
                        .orderBy('createdAt', descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      return ListView(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        children: snapshot.data!.docs.map((doc) {
                          final data =
                              doc.data() as Map<String, dynamic>;

                          return Card(
                            child: ListTile(
                              leading: const Icon(
                                Icons.vaccines,
                                color: Color(0xFF1FAF5A),
                              ),
                              title: Text(data['nom'] ?? ""),
                              subtitle: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text("Centre : ${data['centre'] ?? ''}"),
                                  Text("Date : ${data['date'] ?? ''}"),
                                  if ((data['rappel'] ?? "")
                                      .toString()
                                      .isNotEmpty)
                                    Text("Rappel : ${data['rappel']}"),
                                  if ((data['notes'] ?? "")
                                      .toString()
                                      .isNotEmpty)
                                    Text("Notes : ${data['notes']}"),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
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