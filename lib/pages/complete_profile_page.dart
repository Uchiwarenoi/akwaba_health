import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:akwaba_health/pages/acueill_normal_page.dart';

class CompleteProfilePage extends StatefulWidget {
  const CompleteProfilePage({super.key});

  @override
  State<CompleteProfilePage> createState() =>
      _CompleteProfilePageState();
}

class _CompleteProfilePageState extends State<CompleteProfilePage> {
  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _ageController = TextEditingController();
  final _poidsController = TextEditingController();
  final _tailleController = TextEditingController();

  String selectedGroupe = 'A+';
  bool isLoading = false;

  final List<String> groupes = [
    'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'
  ];

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _ageController.dispose();
    _poidsController.dispose();
    _tailleController.dispose();
    super.dispose();
  }

  Future<void> saveProfile() async {
    if (_nomController.text.trim().isEmpty ||
        _prenomController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Nom et prénom obligatoires"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .set({
        'email': user.email,
        'nom': _nomController.text.trim(),
        'prenom': _prenomController.text.trim(),
        'age': _ageController.text.trim(),
        'poids': _poidsController.text.trim(),
        'taille': _tailleController.text.trim(),
        'groupe_sanguin': selectedGroupe,
        'profileComplete': true,
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const AccueilNormalPage(),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur : $e")),
      );
    }

    if (mounted) {
      setState(() => isLoading = false);
    }
  }

  Widget input(
    TextEditingController controller,
    String hint, {
    IconData? icon,
    TextInputType? type,
  }) {
    return TextField(
      controller: controller,
      keyboardType: type,
      decoration: InputDecoration(
        prefixIcon: icon != null ? Icon(icon) : null,
        hintText: hint,
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.light(),
      child: Scaffold(
      backgroundColor: Colors.white,

      // ✅ APPBAR FIXÉE (retour intelligent)
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => const AccueilNormalPage(),
                ),
              );
            }
          },
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 20),

                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Compléter profil',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Color.fromRGBO(240, 91, 11, 1),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                input(_nomController, "Nom"),
                const SizedBox(height: 16),

                input(_prenomController, "Prénom"),
                const SizedBox(height: 16),

                input(_ageController, "Âge",
                    type: TextInputType.number),
                const SizedBox(height: 16),

                input(_poidsController, "Poids (kg)",
                    icon: Icons.monitor_weight,
                    type: TextInputType.number),
                const SizedBox(height: 16),

                input(_tailleController, "Taille (cm)",
                    icon: Icons.height,
                    type: TextInputType.number),

                const SizedBox(height: 24),

                DropdownButtonFormField<String>(
                  value: selectedGroupe,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.bloodtype),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  items: groupes
                      .map((g) => DropdownMenuItem(
                            value: g,
                            child: Text(g),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedGroupe = value!;
                    });
                  },
                ),

                const SizedBox(height: 30),

                isLoading
                    ? const CircularProgressIndicator()
                    : SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1FAF5A),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: saveProfile,
                          child: const Text(
                            'Enregistrer',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
      ),
    );
  }
}