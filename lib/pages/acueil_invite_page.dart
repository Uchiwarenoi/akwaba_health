import 'package:flutter/material.dart';
import 'package:animated_botton_navigation/animated_botton_navigation.dart';
import 'package:akwaba_health/pages/settings_invit_page.dart';
import 'package:akwaba_health/pages/liste_choix_invite_page.dart';


class AccueilPage extends StatelessWidget {
  const AccueilPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
      const ListeChoix(), 
      const SettingsInvitPage(),  
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 43, 109, 25),
        title: [
          Text("Accueil(mode invité)"),
          Text("Paramètres(mode invité)"),
        ][_currentIndex]
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: AnimatedBottomNavigation(
        height: 70,
        indicatorSpaceBotton: 25,
        icons: [
          Icons.home,
          Icons.settings,
        ],
        currentIndex: _currentIndex,
        onTapChange: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}


