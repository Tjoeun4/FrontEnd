import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:honbop_mate/features/auth/controllers/bottom_nav/community_controller.dart';
import 'package:honbop_mate/features/auth/views/dialog/group_dialog.dart';
import './../components/app_nav_bar.dart';
import './../../views/post_create_screen.dart';
import './../components/bottom_nav_bar.dart';
import './../../../auth/views/dialog/gonggu_dialog.dart';

class CommunityScreen extends StatelessWidget {
 // CommunityScreen({super.key});

  final Controller= Get.find<CommunityController>();
  // final TextEditingController textController;
// final CommunitysearchContoller = TextEditingController();
 
  // const CommunityScreen({
  //   super.key,
  //   required this.textController,
  // });
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppNavBar(title: "게시판"),
      body: Column(
        children: [
        Expanded(
          child: TextField(
           //  controller: textController,
            decoration: InputDecoration(
              hintText: "게시글 검색",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            ),
         //    onSubmitted: (_) => onSearch(),
          ),
        ),

        Expanded(
          child: Row(
           //  controller: textController,
            children: [
              ElevatedButton(
        onPressed: () {
          // 수정 다이얼로그
        },
        child: const Text('전체 갈 텝'),
      ),
      ElevatedButton(
        onPressed: () {
          GongguDialog(context);
        },
        child: const Text('개인 방 생성하기'),
      ),
      // ElevatedButton(
      //   onPressed: () {
      //     GroupDialog(context);
      //   },
      //   child: const Text('공구 / 나눔 방 생성하기'),
      // ),
           

            ]
         //    onSubmitted: (_) => onSearch(),
          ),
        ),
        const SizedBox(width: 8),

        // 3. 게시글/채팅방 리스트 (남은 화면을 꽉 채우도록 Expanded 사용)
          // Expanded(
          //   child: Obx(() {
          //     // 컨트롤러 연결 확인 필요
          //     if (Controller.myRooms.isEmpty) {
          //       return const Center(child: Text("참여 중인 채팅방이 없습니다."));
          //     }

          //     return ListView.builder(
          //       itemCount: Controller.myRooms.length,
          //       itemBuilder: (context, index) {
          //         final room = Controller.myRooms[index];
          //         return ListTile(
          //           leading: const CircleAvatar(
          //             child: Icon(Icons.chat_bubble_outline),
          //           ),
          //           title: Text(room.roomName),
          //           subtitle: Text(room.type),
          //           onTap: () {
          //             print("${room.roomId}번 방으로 이동");
          //           },
          //         );
          //       },
          //     );
          //   }),
          // ),
        ],
      ),
        // ListView(
        //   children: [
        //     Text('12321213213213213'
        //     ),
        //   ],
        // )
        // Obx(() => searchController.isLoading.value
        //     ? const SizedBox(
        //   width: 24,
        //   height: 24,
        //   child: CircularProgressIndicator(strokeWidth: 2),
        // )
        //     : IconButton(
        //   onPressed: (){},
        //   icon: const Icon(Icons.search),
        // )),
         
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