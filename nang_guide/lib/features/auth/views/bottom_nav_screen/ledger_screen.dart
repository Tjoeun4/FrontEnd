import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:honbop_mate/features/auth/views/dialog/ocr_dialog.dart';
import './../../controllers/bottom_nav/ledger_controller.dart';
import './../components/bottom_nav_bar.dart';

class LedgerScreen extends StatelessWidget {
  LedgerScreen({super.key});

  final LedgerController controller = Get.put(LedgerController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              const SizedBox(height: 20),

              // 월 이동
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(
                    onPressed: controller.previousMonth,
                    icon: const Icon(
                      Icons.arrow_back_ios,
                      size: 15,
                      color: Colors.amber,
                    ),
                  ),
                  Obx(
                    () => Text(
                      '${controller.month.value}월',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: controller.nextMonth,
                    icon: const Icon(
                      Icons.arrow_forward_ios,
                      size: 15,
                      color: Colors.amber,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // 요일
              Row(
                children: controller.weekLabels.map((e) {
                  return Expanded(
                    
                    child: Container(
                      alignment: Alignment.center,
                      height: 50,
                      child: Text(
                        e,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              // 날짜
              Obx(
                () => Column(
                  children: List.generate(
                    controller.days.length,
                    (rowIndex) => Row(
                      children: controller.days[rowIndex].map((day) {
                        return Expanded(
                          child: Container(
                            height: 50,
                            alignment: Alignment.center,
                            child: Text(
                              day == 0 ? '' : '$day',
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
              Divider(color: Colors.grey.shade300),

              const Text(
                '기록된 내역이 없습니다.',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),

          // 플로팅 버튼
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.only(
                bottom: 36,
                right: 36,
              ),
              child: FloatingActionButton(
                onPressed: () {
                  OcrDialog(context);
                },
                child: const Icon(Icons.add),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: MyBottomNavigation(),
    );
  }
}
