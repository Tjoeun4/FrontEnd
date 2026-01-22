import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:honbop_mate/features/auth/services/auth_service.dart';
import 'package:honbop_mate/features/auth/services/gongu_service.dart';
import '../controllers/post_controller.dart';
// 서비스 추가할 예정

class PostBinding extends Bindings {
  @override
  void dependencies() {
    // Services
    Get.put<GonguService>(GonguService(), permanent: true);
    Get.put(GetStorage(), permanent: true); // GetX패키지의 의존성 주입(인스턴스 생성 후 메모리에 올림) 메서드. 매번 GetStorage()를 새로 생성할 필요 없이, 메모리에 딱 하나 올라가 있는 '싱글톤(Singleton)' 객체를 공유해서 쓰기 위함
    Get.put(Dio(BaseOptions(baseUrl: 'http://10.0.2.2:8080/api')), permanent: true);
    


    Get.lazyPut(() => PostController());
    // Get.lazyPut<TokenService>(() => TokenService());
  }
}
