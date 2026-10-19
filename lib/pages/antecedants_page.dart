import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AntecedantsTab extends StatefulWidget {
  const AntecedantsTab({super.key});

  @override
  State<AntecedantsTab> createState() => _AntecedantsTabState();
}

class _AntecedantsTabState extends State<AntecedantsTab> {
  final typeController = TextEditingController();
  final nomController = TextEditingController();
  final dateController = TextEditingController();
  final notesController = TextEditingController();

  final uid = FirebaseAuth.instance.currentUser!.uid;

  Future<void> ajouterAntecedant() async {
    if (nomController.text.trim().isEmpty ||
        typeController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Type et nom obligatoires"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('Antecedants')
        .add({
      'type': typeController.text.trim(),
      'nom': nomController.text.trim(),
      'date': dateController.text.trim(),
      'notes': notesController.text.trim(),
      'createdAt': Timestamp.now(),
    });

    typeController.clear();
    nomController.clear();
    dateController.clear();
    notesController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Antécédent ajouté ✅"),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> supprimerAntecedant(DocumentSnapshot doc) async {
    await doc.reference.delete();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Antécédent supprimé ✅"),
        ),
      );
    }
  }

  void modifierAntecedant(
      DocumentSnapshot doc,
      Map<String, dynamic> data,
      ) {
    final typeEdit =
    TextEditingController(text: data['type'] ?? '');

    final nomEdit =
    TextEditingController(text: data['nom'] ?? '');

    final dateEdit =
    TextEditingController(text: data['date'] ?? '');

    final notesEdit =
    TextEditingController(text: data['notes'] ?? '');

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Modifier l'antécédent"),

        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              TextField(
                controller: typeEdit,
                decoration: const InputDecoration(
                  labelText: "Type *",
                ),
              ),

              const SizedBox(height: 10),

              TextField(
                controller: nomEdit,
                decoration: const InputDecoration(
                  labelText: "Nom *",
                ),
              ),

              const SizedBox(height: 10),

              TextField(
                controller: dateEdit,
                decoration: const InputDecoration(
                  labelText: "Date",
                ),
              ),

              const SizedBox(height: 10),

              TextField(
                controller: notesEdit,
                decoration: const InputDecoration(
                  labelText: "Notes",
                ),
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

              await doc.reference.update({
                'type': typeEdit.text.trim(),
                'nom': nomEdit.text.trim(),
                'date': dateEdit.text.trim(),
                'notes': notesEdit.text.trim(),
              });

              Navigator.pop(context);

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Antécédent modifié ✅"),
                  ),
                );
              }
            },
            child: const Text(
              "Enregistrer",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),

      child: Column(
        children: [

          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),

              child: Column(
                children: [

                  TextField(
                    controller: typeController,
                    decoration: const InputDecoration(
                      labelText: "Type *",
                    ),
                  ),

                  const SizedBox(height: 10),

                  TextField(
                    controller: nomController,
                    decoration: const InputDecoration(
                      labelText: "Nom *",
                    ),
                  ),

                  const SizedBox(height: 10),

                  TextField(
                    controller: dateController,
                    decoration: const InputDecoration(
                      labelText: "Date",
                    ),
                  ),

                  const SizedBox(height: 10),

                  TextField(
                    controller: notesController,
                    decoration: const InputDecoration(
                      labelText: "Notes",
                    ),
                  ),

                  const SizedBox(height: 15),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                        Color.fromARGB(255, 243, 190, 94),
                      ),
                      onPressed: ajouterAntecedant,
                      child: const Text(
                        "Ajouter",
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 15),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(uid)
                  .collection('Antecedants')
                  .orderBy(
                'createdAt',
                descending: true,
              )
                  .snapshots(),

              builder: (context, snapshot) {

                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                      "Aucun antécédent enregistré",
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,

                  itemBuilder: (context, index) {

                    final doc =
                    snapshot.data!.docs[index];

                    final data =
                    doc.data() as Map<String, dynamic>;

                    return Card(
                      margin: const EdgeInsets.only(
                        bottom: 10,
                      ),

                      child: ListTile(
                        leading: const Icon(
                          Icons.history_edu,
                          color: Colors.orange,
                        ),

                        title: Text(
                          data['nom'] ?? '',
                        ),

                        subtitle: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [

                            Text(
                              "Type : ${data['type'] ?? ''}",
                            ),

                            Text(
                              "Date : ${data['date'] ?? ''}",
                            ),

                            Text(
                              "Notes : ${data['notes'] ?? ''}",
                            ),
                          ],
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

                            if (value == "edit") {
                              modifierAntecedant(
                                doc,
                                data,
                              );
                            }

                            if (value == "delete") {
                              supprimerAntecedant(doc);
                            }
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}