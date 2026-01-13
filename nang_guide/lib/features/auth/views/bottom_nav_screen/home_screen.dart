import 'package:flutter/material.dart';
import './../components/bottom_nav_bar.dart';

class HomeScreen extends StatelessWidget {
  
  HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const Center(
        child: Text(
          'Home Screen',
          style: TextStyle(fontSize: 24),
        ),
      ),
      bottomNavigationBar: MyBottomNavigation(),
    );
  }
}