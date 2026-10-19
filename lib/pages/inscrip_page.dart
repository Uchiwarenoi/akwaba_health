import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:akwaba_health/pages/complete_profile_page.dart';
 
class SignInPage extends StatefulWidget {
  const SignInPage({Key? key}) : super(key: key);
 
  @override
  State<SignInPage> createState() => _SignInPageState();
}
 
class _SignInPageState extends State<SignInPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
 
  bool isLoading = false;
  bool obscurePassword = true;


  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
 
  // 🔥 INSCRIPTION
  Future register() async {
    setState(() => isLoading = true);
 
    try {
      // Vérification mots de passe
      if (_passwordController.text.trim() !=
          _confirmPasswordController.text.trim()) {
        throw Exception("Les mots de passe ne correspondent pas");
      }
 
      //  Création compte Firebase Auth
      final userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
 
      final user = userCredential.user;
 
      // 💾 Sauvegarde dans Firestore (PRO)
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid);
          
 
      // Navigation
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => CompleteProfilePage()),
      );
    } on FirebaseAuthException catch (e) {
      String message = "Erreur";
 
      if (e.code == 'email-already-in-use') {
        message = "Email déjà utilisé";
      } else if (e.code == 'weak-password') {
        message = "Mot de passe trop faible";
      } else if (e.code == 'invalid-email') {
        message = "Email invalide";
      }
 
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
 
    setState(() => isLoading = false);
  }
 
  @override
  Widget build(BuildContext context) {
    return Theme(
    data: ThemeData.light(),
    child: Scaffold(
    backgroundColor: Colors.white,

  appBar: AppBar(
    backgroundColor: Colors.white,
    elevation: 0,
    leading: IconButton(
      icon: const Icon(Icons.arrow_back, color: Colors.black),
      onPressed: () {
        Navigator.pop(context); // retour page précédente
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
                    'Inscription',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Color.fromRGBO(240, 91, 11, 1)
                    ),
                  ),
                ),
            const SizedBox(height: 30),

            TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.email_outlined),
                    hintText: 'Email',
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
 
            const SizedBox(height: 16),
 
             TextField(
                  controller: _passwordController,
                  obscureText: obscurePassword,
                  decoration: InputDecoration(
                    prefixIcon:
                        const Icon(Icons.lock_outline),
                    hintText: 'Mot de passe',
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility),
                      onPressed: () {
                        setState(() {
                          obscurePassword =
                              !obscurePassword;
                        });
                      },
                    ),
                  ),
                ),
 
            const SizedBox(height: 16),
 
            TextField(
              controller: _confirmPasswordController,
                  obscureText: obscurePassword,
                  decoration: InputDecoration(
                    prefixIcon:
                        const Icon(Icons.lock_outline),
                    hintText: 'Confirmer le mot de passe',
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility),
                      onPressed: () {
                        setState(() {
                          obscurePassword =
                              !obscurePassword;
                        });
                      },
                    ),
                  ),
            ),
 
            const SizedBox(height: 24),
 
            isLoading
                ? const CircularProgressIndicator()
                    : SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color(0xFF1FAF5A),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: register,
                          child: const Text(
                            'Créer un compte',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),

          ],
        ),
      ),
    )
      ),
    ),
     );
  }
}