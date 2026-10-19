import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MaladiesTab extends StatefulWidget {
  const MaladiesTab({super.key});

  @override
  State<MaladiesTab> createState() => _MaladiesTabState();
}

class _MaladiesTabState extends State<MaladiesTab> {
  final nomController = TextEditingController();
  final traitementController = TextEditingController();
  final statutController = TextEditingController();
  final notesController = TextEditingController();
  final dateDiagnosticController = TextEditingController();

  final uid = FirebaseAuth.instance.currentUser!.uid;

  Future<void> ajouterMaladie() async {
    if (nomController.text.trim().isEmpty ||
        traitementController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Nom et traitement obligatoires"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('Maladies')
        .add({
      'nom': nomController.text.trim(),
      'dateDiagnostic': dateDiagnosticController.text.trim(),
      'traitement': traitementController.text.trim(),
      'statut': statutController.text.trim(),
      'notes': notesController.text.trim(),
      'createdAt': Timestamp.now(),
    });

    nomController.clear();
    traitementController.clear();
    statutController.clear();
    notesController.clear();
    dateDiagnosticController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Maladie ajoutée ✅"),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> supprimerMaladie(DocumentSnapshot doc) async {
    await doc.reference.delete();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Maladie supprimée ✅"),
        ),
      );
    }
  }

  void modifierMaladie(
    DocumentSnapshot doc,
    Map<String, dynamic> data,
  ) {
    final nomEdit =
        TextEditingController(text: data['nom'] ?? '');

    final traitementEdit =
        TextEditingController(text: data['traitement'] ?? '');

    final statutEdit =
        TextEditingController(text: data['statut'] ?? '');

    final diagnosticEdit =
        TextEditingController(
            text: data['dateDiagnostic'] ?? '');

    final notesEdit =
        TextEditingController(text: data['notes'] ?? '');

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Modifier maladie"),

        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              TextField(
                controller: nomEdit,
                decoration: const InputDecoration(
                  labelText: "Nom *",
                ),
              ),

              const SizedBox(height: 10),

              TextField(
                controller: traitementEdit,
                decoration: const InputDecoration(
                  labelText: "Traitement *",
                ),
              ),

              const SizedBox(height: 10),

              TextField(
                controller: statutEdit,
                decoration: const InputDecoration(
                  labelText: "Statut",
                ),
              ),

              const SizedBox(height: 10),

              TextField(
                controller: diagnosticEdit,
                decoration: const InputDecoration(
                  labelText: "Date du diagnostic",
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
                'nom': nomEdit.text.trim(),
                'traitement':
                    traitementEdit.text.trim(),
                'statut': statutEdit.text.trim(),
                'dateDiagnostic':
                    diagnosticEdit.text.trim(),
                'notes': notesEdit.text.trim(),
              });

              Navigator.pop(context);

              if (mounted) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(
                  const SnackBar(
                    content:
                        Text("Maladie modifiée ✅"),
                  ),
                );
              }
            },
            child: const Text(
              "Enregistrer",
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),

        child: SingleChildScrollView(
        child: Column(
        children: [

          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),

              child: Column(
                children: [

                  TextField(
                    controller: nomController,
                    decoration: const InputDecoration(
                      labelText: "Nom de la maladie *",
                    ),
                  ),

                  const SizedBox(height: 10),

                  TextField(
                    controller: traitementController,
                    decoration: const InputDecoration(
                      labelText: "Traitement *",
                    ),
                  ),

                  const SizedBox(height: 10),

                  TextField(
                    controller: statutController,
                    decoration: const InputDecoration(
                      labelText: "Statut",
                    ),
                  ),

                  const SizedBox(height: 10),

                  TextField(
                    controller:
                        dateDiagnosticController,
                    decoration: const InputDecoration(
                      labelText:
                          "Date du diagnostic",
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
                            Color(0xFF6EEB83),
                      ),
                      onPressed: ajouterMaladie,
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

          StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(uid)
                  .collection('Maladies')
                  .orderBy(
                    'createdAt',
                    descending: true,
                  )
                  .snapshots(),

              builder: (context, snapshot) {

                if (!snapshot.hasData) {
                  return const Center(
                    child:
                        CircularProgressIndicator(),
                  );
                }

                if (snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                      "Aucune maladie enregistrée",
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: snapshot.data!.docs.length,

                  itemBuilder: (context, index) {

                    final doc =
                        snapshot.data!.docs[index];

                    final data =
                        doc.data()
                            as Map<String, dynamic>;

                    return Card(
                      margin:
                          const EdgeInsets.only(
                        bottom: 10,
                      ),

                      child: ListTile(
                        leading: const Icon(
                          Icons.health_and_safety,
                          color: Colors.red,
                        ),

                        title: Text(
                          data['nom'] ?? '',
                        ),

                        subtitle: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                          children: [

                            Text(
                              "Traitement : ${data['traitement'] ?? ''}",
                            ),

                            Text(
                              "Statut : ${data['statut'] ?? ''}",
                            ),

                            Text(
                              "Diagnostic : ${data['dateDiagnostic'] ?? ''}",
                            ),

                            Text(
                              "Notes : ${data['notes'] ?? ''}",
                            ),
                          ],
                        ),

                        trailing:
                            PopupMenuButton(
                          itemBuilder: (_) =>
                              const [

                            PopupMenuItem(
                              value: "edit",
                              child:
                                  Text("Modifier"),
                            ),

                            PopupMenuItem(
                              value: "delete",
                              child: Text(
                                  "Supprimer"),
                            ),
                          ],

                          onSelected: (value) {

                            if (value ==
                                "edit") {
                              modifierMaladie(
                                doc,
                                data,
                              );
                            }

                            if (value ==
                                "delete") {
                              supprimerMaladie(
                                doc,
                              );
                            }
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
    );
  }
}