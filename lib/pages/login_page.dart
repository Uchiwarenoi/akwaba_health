import 'package:akwaba_health/pages/acueill_normal_page.dart';
import 'package:akwaba_health/pages/inscrip_page.dart';
import 'package:akwaba_health/pages/acueil_invite_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_button/sign_in_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:akwaba_health/pages/complete_profile_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool isLoading = false;
  bool obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // 🔐 LOGIN EMAIL
  Future<void> login() async {
    setState(() => isLoading = true);

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AccueilNormalPage()),
      );
    } on FirebaseAuthException catch (e) {
      String message = "Erreur";

      if (e.code == 'user-not-found') {
        message = "Utilisateur introuvable";
      } else if (e.code == 'wrong-password') {
        message = "Mot de passe incorrect";
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }

    setState(() => isLoading = false);
  }

  // GOOGLE LOGIN
  Future<void> signInWithGoogle() async {
  setState(() => isLoading = true);

  try {
    final GoogleSignIn googleSignIn = GoogleSignIn();

    final GoogleSignInAccount? googleUser =
        await googleSignIn.signIn();

    if (googleUser == null) {
      setState(() => isLoading = false);
      return;
    }

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCredential =
        await FirebaseAuth.instance.signInWithCredential(
      credential,
    );

    final user = userCredential.user!;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (!doc.exists) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set({
        'email': user.email,
        'profileComplete': false,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const CompleteProfilePage(),
        ),
      );
    } else {
      final data = doc.data();

      if (data?['profileComplete'] == true) {
        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const AccueilNormalPage(),
          ),
        );
      } else {
        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const CompleteProfilePage(),
          ),
        );
      }
    }
  } catch (e) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Erreur Google : $e"),
      ),
    );
  }

  if (mounted) {
    setState(() => isLoading = false);
  }
}
  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.light(),
      child: Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 20),

                // LOGO
                Column(
                  children: [
                    Image.asset(
                      "assets/images/Akwaba.png",
                      width: 200,
                      height: 200,
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // TITRE
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Connexion',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Color.fromRGBO(240, 91, 11, 1)
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // EMAIL
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

                // 🔒 PASSWORD
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

                const SizedBox(height: 20),

                // 🔐 LOGIN BUTTON
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
                          onPressed: login,
                          child: const Text(
                            'Connexion',
                            style: TextStyle(fontSize: 16, color: Colors.black),
                          ),
                        ),
                      ),

                const SizedBox(height: 20),

                // ➖ DIVIDER
                Row(
                  children: const [
                    Expanded(child: Divider()),
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 10),
                      child: Text('ou'),
                    ),
                    Expanded(child: Divider()),
                  ],
                ),

                const SizedBox(height: 20),

                // 🔵 GOOGLE BUTTON
                SignInButton(
                  Buttons.google,
                  text: "Se connecter avec Google",
                  onPressed: signInWithGoogle,
                ),

                const SizedBox(height: 30),

                // 🔗 SIGN UP
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  children: [
                    const Text(
                        "Vous n'avez pas de compte ? "),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const SignInPage(),
                          ),
                        );
                      },
                      child: const Text(
                        'Créer un compte',
                        style: TextStyle(
                          color: Color.fromARGB(255, 19, 192, 249),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // 👤 MODE INVITÉ
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                              const AccueilPage()),
                    );
                  },
                  child: const Text('Mode invité', style: TextStyle(color: Color.fromARGB(255, 19, 192, 249)),),
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
      ),
    );
  }
}