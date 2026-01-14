import 'package:flutter/material.dart';
import './../components/app_nav_bar.dart';
import './../components/bottom_nav_bar.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppNavBar(title: "내 프로필"),
      body: const Center(
        child: Text(
          '프로필 Screen',
          style: TextStyle(fontSize: 24),
        ),
      ),
      bottomNavigationBar: MyBottomNavigation(),
    );
  }
}