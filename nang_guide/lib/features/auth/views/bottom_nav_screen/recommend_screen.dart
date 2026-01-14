import 'package:flutter/material.dart';
import './../components/app_nav_bar.dart';
import './../components/bottom_nav_bar.dart';

class RecommendScreen extends StatelessWidget {
  const RecommendScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppNavBar(title: "음식 추천"),
      body: const Center(
        child: Text(
          '레시피 추천 Screen',
          style: TextStyle(fontSize: 24),
        ),
      ),
      bottomNavigationBar: MyBottomNavigation(),
    );
  }
}