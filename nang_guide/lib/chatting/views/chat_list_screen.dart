import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:honbop_mate/chatting/controller/chat_controller.dart';
import 'package:honbop_mate/chatting/model/chat_model.dart';
import 'package:honbop_mate/core/design/app_design.dart';
import 'package:honbop_mate/routes/app_routes.dart';

class ChatListScreen extends StatelessWidget {
  ChatListScreen({super.key});

  final ChatController controller = Get.put(ChatController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text("채팅 목록", style: AppTextStyles.bodyLargeBold),
        backgroundColor: AppColors.background,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Get.offAllNamed(AppRoutes.HOME);
          },
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: controller.chatRooms.length,
          itemBuilder: (context, index) {
            // ✅ 관찰 중인 리스트에서 직접 추출하여 실시간 변화 감지
            final room = controller.chatRooms[index];

            return GestureDetector(
              onTap: () {
                final storage = GetStorage();
                final myId = storage.read('userId'); // 👈 여기서 꺼내 쓰기!

                if (myId == null) {
                  print("❌ 아직 로그인이 덜 됐나 봐요! ID가 없어요.");
                  return;
                }
                controller.connect(room.roomId);
                Get.toNamed(
                  AppRoutes.CHAT_ROOM, // 'chat/room/1' 이런 식보다 상수를 쓰는 게 안전합니다.
                  arguments: {
                    'roomId': room.roomId,
                    'roomName': room.roomName,
                    'currentUserId': controller.currentUserId ?? 0, // null 방지
                  },
                );
              },
              child: Container(
                margin: EdgeInsets.only(
                  bottom: AppSpacing.md,
                  left: AppSpacing.sm,
                  right: AppSpacing.sm,
                ),
                padding: AppSpacing.paddingLG,
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: AppBorderRadius.containerRadius,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.textSecondary.withOpacity(0.1),
                      spreadRadius: 2,
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // ✅ 에러 해결: 하단에 정의된 _buildRoomIcon 호출
                    _buildRoomIcon(room.type),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            room.roomName,
                            style: AppTextStyles.bodyLargeBold,
                          ),
                          const SizedBox(height: 5),
                          // 🔴 실시간 반영되는 마지막 메시지 영역
                          Text(
                            room.lastMessage ?? "메시지가 없습니다",
                            style: AppTextStyles.bodySmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    // 안읽은 메시지 알림 (디자인 유지)
                    if (room.unreadCount > 0)
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: AppColors.error,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          "${room.unreadCount}",
                          style: TextStyle(
                            color: AppColors.textWhite,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }

  // ✅ 에러 해결: 누락되었던 아이콘 빌더 함수 정의
  Widget _buildRoomIcon(ChatRoomType type) {
    IconData iconData;
    Color iconColor;

    switch (type) {
      case ChatRoomType.GROUP_BUY:
        iconData = Icons.groups;
        iconColor = AppColors.primary;
        break;
      case ChatRoomType.FAMILY:
        iconData = Icons.home;
        iconColor = AppColors.success;
        break;
      default:
        iconData = Icons.person;
        iconColor = AppColors.info;
    }

    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(iconData, color: iconColor),
    );
  }
} // ✅ 에러 해결: 클래스 닫는 중괄호 위치 확인
