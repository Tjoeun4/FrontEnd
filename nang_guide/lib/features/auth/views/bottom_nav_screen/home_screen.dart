import 'package:flutter/material.dart';
import './../components/app_nav_bar.dart';
import './../components/bottom_nav_bar.dart';

class HomeScreen extends StatelessWidget {
  
  HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppNavBar(title: "냉가이드"),
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