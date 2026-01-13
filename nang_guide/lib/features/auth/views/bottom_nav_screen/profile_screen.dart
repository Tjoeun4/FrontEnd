import 'package:flutter/material.dart';
import './../components/bottom_nav_bar.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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