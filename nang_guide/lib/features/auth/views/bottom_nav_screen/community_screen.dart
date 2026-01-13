import 'package:flutter/material.dart';
import './../components/bottom_nav_bar.dart';

class CommunityScreen extends StatelessWidget {

  CommunityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const Center(
        child: Text(
          'Community Screen',
          style: TextStyle(fontSize: 24),
        ),
      ),
      bottomNavigationBar: MyBottomNavigation(),
    );
  }
}