import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MedicamentsPage extends StatefulWidget {
  const MedicamentsPage({super.key});

  @override
  State<MedicamentsPage> createState() => _MedicamentsPageState();
}

class _MedicamentsPageState extends State<MedicamentsPage> {
  final nomController = TextEditingController();
  final dosageController = TextEditingController();
  final frequenceController = TextEditingController();
  final notesController = TextEditingController();

  DateTime? dateDebut;
  DateTime? dateFin;

  final user = FirebaseAuth.instance.currentUser!;

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
            Icon(Icons.medication, color: Colors.white, size: 40),
            SizedBox(height: 10),
            Text(
              "Médicaments",
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
  Future<void> pickDate(bool debut) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        debut ? dateDebut = picked : dateFin = picked;
      });
    }
  }

  Future<void> ajouterMedicament() async {
    if (nomController.text.trim().isEmpty ||
        dosageController.text.trim().isEmpty) {
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
        .doc(user.uid)
        .collection('Medicaments')
        .add({
      'nom': nomController.text.trim(),
      'dosage': dosageController.text.trim(),
      'frequence': frequenceController.text.trim(),
      'notes': notesController.text.trim(),
      'dateDebut': dateDebut == null
          ? ""
          : "${dateDebut!.day}/${dateDebut!.month}/${dateDebut!.year}",
      'dateFin': dateFin == null
          ? ""
          : "${dateFin!.day}/${dateFin!.month}/${dateFin!.year}",
      'createdAt': Timestamp.now(),
    });

    nomController.clear();
    dosageController.clear();
    frequenceController.clear();
    notesController.clear();

    setState(() {
      dateDebut = null;
      dateFin = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("✅ Médicament ajouté"),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> deleteMed(String id) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('Medicaments')
        .doc(id)
        .delete();
  }

  void editMed(String id, Map<String, dynamic> data) {
    final nom = TextEditingController(text: data['nom']);
    final dosage = TextEditingController(text: data['dosage']);
    final freq = TextEditingController(text: data['frequence']);
    final notes = TextEditingController(text: data['notes']);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Modifier médicament"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nom),
            TextField(controller: dosage),
            TextField(controller: freq),
            TextField(controller: notes),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Annuler"),
          ),
          ElevatedButton(
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(user.uid)
                  .collection('Medicaments')
                  .doc(id)
                  .update({
                'nom': nom.text,
                'dosage': dosage.text,
                'frequence': freq.text,
                'notes': notes.text,
              });

              Navigator.pop(context);
            },
            child: const Text("OK"),
          ),
        ],
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
              padding: const EdgeInsets.all(12),
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
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        children: [
                          TextField(
                            controller: nomController,
                            decoration: const InputDecoration(
                              labelText: "Nom *",
                            ),
                          ),
                          TextField(
                            controller: dosageController,
                            decoration: const InputDecoration(
                              labelText: "Dosage *",
                            ),
                          ),
                          TextField(
                            controller: frequenceController,
                            decoration: const InputDecoration(
                              labelText: "Fréquence",
                            ),
                          ),

                          Row(
                            children: [
                              Expanded(
                                child: TextButton(
                                  onPressed: () => pickDate(true),
                                  child: Text(
                                    dateDebut == null ? "Début" : "OK",
                                  ),
                                ),
                              ),
                              Expanded(
                                child: TextButton(
                                  onPressed: () => pickDate(false),
                                  child: Text(
                                    dateFin == null ? "Fin" : "OK",
                                  ),
                                ),
                              ),
                            ],
                          ),

                          TextField(
                            controller: notesController,
                            maxLines: 2,
                            decoration: const InputDecoration(
                              labelText: "Notes",
                            ),
                          ),

                          const SizedBox(height: 10),

                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color.fromARGB(255, 243, 190, 94),
                              ),
                              onPressed: ajouterMedicament,
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

                  const SizedBox(height: 10),

                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .doc(user.uid)
                        .collection('Medicaments')
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
                                Icons.medication,
                                color: Colors.green,
                              ),
                              title: Text(data['nom'] ?? ""),
                              subtitle: Text(
                                "Dosage: ${data['dosage']}",
                              ),
                              trailing: PopupMenuButton(
                                itemBuilder: (_) => const [
                                  PopupMenuItem(
                                    value: "edit",
                                    child: Text("Modifier"),
                                  ),
                                  PopupMenuItem(
                                    value: "delete",
                                    child: Text("Supprimer"),
                                  ),
                                ],
                                onSelected: (value) {
                                  if (value == "delete") {
                                    deleteMed(doc.id);
                                  }
                                  if (value == "edit") {
                                    editMed(doc.id, data);
                                  }
                                },
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