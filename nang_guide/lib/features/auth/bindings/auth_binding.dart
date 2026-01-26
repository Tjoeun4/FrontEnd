import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:dio/dio.dart'; // Dio import
import '../controllers/auth_controller.dart';
import '../controllers/bottom_nav/nav_controller.dart';
import '../services/auth_api_client.dart';
import '../services/google_auth_service.dart';
import '../services/token_service.dart'; // TokenService import

class AuthBinding extends Bindings {
  // Bindings 클래스는 "앱이 특정 화면에 진입하거나 시작될 때, 필요한 도구(컨트롤러, 서비스 등)를 메모리에 미리 준비해두는 설정 파일" 역할
  @override
  void dependencies() {
    // 이 메서드 안에 우리가 메모리에 올리고 싶은 클래스들을 정의
    // Services

    // 1. 로컬 저장소 서비스: 로그인 토큰, 유저 설정 등을 기기에 영구 저장하기 위해 사용
    // permanent: true는 앱이 꺼질 때까지 메모리에서 삭제하지 말라는 의미입니다.
    Get.put(GetStorage(), permanent: true); // GetX패키지의 의존성 주입(인스턴스 생성 후 메모리에 올림) 메서드. 매번 GetStorage()를 새로 생성할 필요 없이, 메모리에 딱 하나 올라가 있는 '싱글톤(Singleton)' 객체를 공유해서 쓰기 위함
    
    // 2. HTTP 통신 클라이언트(Dio): 백엔드 서버(API)와 통신하기 위한 객체
    // 서버 주소(baseUrl)를 설정하여 모든 API 호출의 기본 경로를 지정합니다.
    Get.put(Dio(BaseOptions(baseUrl: 'http://10.0.2.2:8080/api')), permanent: true);

    // 3. 구글 로그인 서비스: 소셜 로그인을 담당하는 로직
    Get.put<GoogleAuthService>(GoogleAuthService(), permanent: true);

    // 4. 토큰 관리 서비스: 서버에서 받은 JWT 토큰을 관리하고, Dio를 사용하여 요청 헤더에 토큰을 넣어주는 역할
    // Get.find<Dio>()를 통해 위에서 만든 Dio 인스턴스를 주입받습니다.
    Get.put<TokenService>(TokenService(Get.find<Dio>()), permanent: true);

    // 5. 인증 API 클라이언트: 실제 로그인, 회원가입 API를 호출하는 서비스
    // TokenService 이후에 등록해야 토큰을 이용한 API 호출이 가능합니다.
    Get.put<AuthApiClient>(AuthApiClient(), permanent: true);

    // 6. 컨트롤러들: 화면의 상태를 관리하고 비즈니스 로직을 실행
    Get.put<AuthController>(AuthController(), permanent: true); // 유저 인증 상태 관리
    Get.put<NavController>(NavController(), permanent: true); // NavController를 영구 종속성으로 추가// 하단 네비게이션 상태 관리
  }
}
