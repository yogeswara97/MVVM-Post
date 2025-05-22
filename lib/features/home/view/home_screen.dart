import 'package:flutter/material.dart';
import '../../../widgets/drawer_menu.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const DrawerMenu(),
      appBar: AppBar(title: const Text('Home')),
      body: const Center(child: Text('Welcome to Home Page!')),
    );
  }
}
