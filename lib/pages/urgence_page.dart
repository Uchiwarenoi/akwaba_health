import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';

class UrgencePage extends StatefulWidget {
  const UrgencePage({super.key});

  @override
  State<UrgencePage> createState() => _UrgencePageState();
}

class _UrgencePageState extends State<UrgencePage> {
  final uid = FirebaseAuth.instance.currentUser!.uid;

  final nomController = TextEditingController();
  final telephoneController = TextEditingController();
  final notesController = TextEditingController();

  @override
  void dispose() {
    nomController.dispose();
    telephoneController.dispose();
    notesController.dispose();
    super.dispose();
  }

  // ---------------- CALL ----------------
  Future<void> appelerNumero(String numero) async {
    final uri = Uri(scheme: 'tel', path: numero);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  // ---------------- HEADER ----------------
  Widget buildHeader() {
    return Container(
      height: 180,
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.warning, color: Colors.white, size: 40),
          SizedBox(height: 10),
          Text(
            "Urgence",
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- AJOUT CONTACT ----------------
  Future<void> ajouterContact() async {
    if (nomController.text.trim().isEmpty ||
        telephoneController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Nom et téléphone obligatoires"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .collection("Urgence")
        .add({
      "nomContact": nomController.text.trim(),
      "telephoneContact": telephoneController.text.trim(),
      "notes": notesController.text.trim(),
      "createdAt": Timestamp.now(),
    });

    nomController.clear();
    telephoneController.clear();
    notesController.clear();

    setState(() {});

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Contact ajouté ✅"),
        backgroundColor: Colors.green,
      ),
    );
  }

  // ---------------- EDIT CONTACT ----------------
  Future<void> modifierContact(
    DocumentSnapshot doc,
    Map<String, dynamic> data,
  ) async {
    final nomEdit = TextEditingController(text: data['nomContact']);
    final telEdit = TextEditingController(text: data['telephoneContact']);
    final notesEdit = TextEditingController(text: data['notes']);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Modifier contact"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nomEdit),
            TextField(controller: telEdit),
            TextField(controller: notesEdit),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Annuler"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await doc.reference.update({
                "nomContact": nomEdit.text.trim(),
                "telephoneContact": telEdit.text.trim(),
                "notes": notesEdit.text.trim(),
              });

              Navigator.pop(context);
            },
            child: const Text("Enregistrer"),
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
          buildHeader(),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.red),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        const Text(
                          "INFORMATIONS CRITIQUES",
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 10),

                        // GROUPE SANGUIN
                        StreamBuilder<DocumentSnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection("users")
                              .doc(uid)
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) return const SizedBox();

                            final data = snapshot.data!.data()
                                as Map<String, dynamic>?;

                            return Text(
                              "🩸 Groupe sanguin : ${data?['groupe_sanguin'] ?? 'Non renseigné'}",
                              style: const TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 10),

                        const Text(
                          "🏥 Maladies :",
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection("users")
                              .doc(uid)
                              .collection("Maladies")
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) return const SizedBox();

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: snapshot.data!.docs.map((doc) {
                                final d = doc.data() as Map<String, dynamic>;
                                return Text("• ${d['nom']}",
                                style: const TextStyle(
                                color: Colors.black,),);
                              }).toList(),
                            );
                          },
                        ),

                        const SizedBox(height: 10),

                        const Text(
                          "📋 Antécédents :",
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection("users")
                              .doc(uid)
                              .collection("Antecedants")
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) return const SizedBox();

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: snapshot.data!.docs.map((doc) {
                                final d = doc.data() as Map<String, dynamic>;
                                return Text("• ${d['nom']}",
                                style: const TextStyle(color: Colors.black),);
                              }).toList(),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      icon: const Icon(Icons.local_hospital, color: Colors.white),
                      label: const Text(
                        "SAMU - 185",
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: () => appelerNumero("185"),
                    ),
                  ),

                  const SizedBox(height: 10),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      icon: const Icon(Icons.local_fire_department, color: Colors.white),
                      label: const Text(
                        "Pompiers - 180",
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: () => appelerNumero("180"),
                    ),
                  ),

                  const SizedBox(height: 10),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      icon: const Icon(Icons.local_police, color: Colors.white),
                      label: const Text(
                        "Police - 111",
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: () => appelerNumero("111"),
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    "Ajouter un contact d'urgence",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),

                  TextField(
                    controller: nomController,
                    decoration: const InputDecoration(labelText: "Nom *"),
                  ),
                  TextField(
                    controller: telephoneController,
                    decoration: const InputDecoration(labelText: "Téléphone *"),
                  ),
                  TextField(
                    controller: notesController,
                    decoration: const InputDecoration(labelText: "Notes"),
                  ),

                  const SizedBox(height: 10),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      onPressed: ajouterContact,
                      child: const Text("Ajouter",
                      style:TextStyle(color: Colors.white)),
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    "Contacts d'urgence",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),

                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection("users")
                        .doc(uid)
                        .collection("Urgence")
                        .orderBy("createdAt", descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const CircularProgressIndicator();
                      }

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          final doc = snapshot.data!.docs[index];
                          final data = doc.data() as Map<String, dynamic>;

                          return Card(
                            child: ListTile(
                              leading: const Icon(Icons.warning, color: Colors.red),
                              title: Text(data['nomContact'] ?? ''),
                              subtitle: Text(data['telephoneContact'] ?? ''),
                              trailing: PopupMenuButton(
                                itemBuilder: (_) => const [
                                  PopupMenuItem(value: "call", child: Text("Appeler")),
                                  PopupMenuItem(value: "edit", child: Text("Modifier")),
                                  PopupMenuItem(value: "delete", child: Text("Supprimer")),
                                ],
                                onSelected: (value) async {
                                  if (value == "call") {
                                    appelerNumero(data['telephoneContact']);
                                  }
                                  if (value == "edit") {
                                    modifierContact(doc, data);
                                  }
                                  if (value == "delete") {
                                    await doc.reference.delete();
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
        ],
      ),
    );
  }
}