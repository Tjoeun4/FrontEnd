import 'package:flutter/material.dart';
import 'package:honbop_mate/features/auth/views/post_create_screen.dart';
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
      // 게시글 작성 플로팅 버튼
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orange,
        child: const Icon(Icons.edit, color: Colors.white),
        onPressed: () {
          // Navigator를 이용한 화면 이동
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const PostCreateScreen()),
          );
        },
      ),
      bottomNavigationBar: MyBottomNavigation(),
    );
  }
}