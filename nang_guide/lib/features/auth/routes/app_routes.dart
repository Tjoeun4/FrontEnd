import 'package:get/get.dart';
import 'package:honbop_mate/features/auth/views/post_create_screen.dart';

// 바인딩
import '../../fridge/bindings/fridge_binding.dart';
import '../../fridge/views/fridge_add_step_screen.dart';
import '../../fridge/views/fridge_list_screen.dart';
import './../bindings/top_nav/alarm_binding.dart';
import './../bindings/auth_binding.dart';
import './../bindings/top_nav/chat_binding.dart';
import './../bindings/bottom_nav/community_binding.dart';
import './../bindings/bottom_nav/ledger_binding.dart';
import './../bindings/login/login_binding.dart';
import './../bindings/post_binding.dart';
import './../bindings/bottom_nav/profile_binding.dart';
import './../bindings/bottom_nav/recommend_binding.dart';
import './../bindings/login/signin_binding.dart';
import './../bindings/login/signup_binding.dart';
import './../bindings/bottom_nav/home_binding.dart';
import './../bindings/post_detail_binding.dart';
import './../bindings/top_nav/chat_room_binding.dart';
import './../bindings/top_nav/chat_binding.dart';

// 뷰
import './../views/bottom_nav_screen/home_screen.dart';
import './../views/bottom_nav_screen/community_screen.dart';
import './../views/bottom_nav_screen/ledger_screen.dart';
import './../views/bottom_nav_screen/profile_screen.dart';
import './../views/bottom_nav_screen/recommend_screen.dart';
import '../views/auth/email_signup_screen.dart';
import '../views/auth/email_login_screen.dart';
import './../views/splash_screen.dart';
import '../views/auth/login_selection_screen.dart';
import '../views/post_detail_screen.dart';
import '../views/chat_screen.dart';
import '../views/chat_list_screen.dart';

class AppRoutes {
  static const SPLASH = '/';
  static const LOGIN = '/login'; // 로그인 선택 화면
  static const SIGNUP = '/signup'; // 이메일 회원가입
  static const SIGNIN = '/signin'; // 이메일 로그인
  static const HOME = '/home'; // 홈 화면
  static const SEARCH = '/search'; // 검색
  static const ALARM = '/alarm'; // 알림
  static const COMMUNITY = '/community'; // 커뮤니티
  static const RECOMMEND = '/recommend'; // 음식 맞춤 추천
  static const LEDGER = '/ledger'; // 가계부
  static const PROFILE = '/profile'; // 프로필
  static const POST = '/post'; // 게시글 작성
  static const CHAT = '/chat'; // 채팅
  static const POST_DETAIL = '/post-detail/:postId'; // 상세페이지
  static const CHAT_LIST = '/chat/list'; // 채팅목록
  static const CHAT_ROOM = '/chat/room/:roomId'; // 채팅방
  static const FRIDGE = '/fridge'; // 내 냉장고 탭
  static const FRIDGE_ADD = '/fridge/add'; // 냉장고에 식재료 추가

  static final routes = [
    GetPage(name: SPLASH, page: () => SplashScreen(), binding: AuthBinding()),
    GetPage(
      name: SIGNUP,
      page: () => EmailSignUpScreen(),
      binding: SignupBinding(),
      transition: Transition.noTransition,
    ),
    GetPage(
      name: SIGNIN,
      page: () => EmailLoginScreen(),
      binding: SigninBinding(),
      transition: Transition.noTransition,
    ),
    GetPage(
      name: LOGIN,
      page: () => LoginSelectionScreen(),
      binding: LoginBinding(),
      // middlewares: [AuthMiddleware(), OwnerMiddleware()],
      transition: Transition.noTransition,
    ),
    GetPage(
      name: HOME,
      page: () => HomeScreen(),
      binding: HomeBinding(),
      transition: Transition.noTransition,
    ), // name과 page 요소는 각각 라우트 경로와 해당 위젯을 매핑, binding은 해당 위젯으로 이동할 때 주입할 의존성 관리 파일(컨트롤러), transition은 화면 전환 혹은 화면 전환 전 조건 검사
    GetPage(name: ALARM, page: () => SplashScreen(), binding: AlarmBinding()),
    GetPage(
      name: COMMUNITY,
      page: () => CommunityScreen(),
      binding: CommunityBinding(),
      transition: Transition.noTransition,
    ),
    GetPage(
      name: RECOMMEND,
      page: () => RecommendScreen(),
      binding: RecommendBinding(),
      transition: Transition.noTransition,
    ),
    GetPage(
      name: LEDGER,
      page: () => LedgerScreen(),
      binding: LedgerBinding(),
      transition: Transition.noTransition,
    ),
    GetPage(
      name: PROFILE,
      page: () => ProfileScreen(),
      binding: ProfileBinding(),
      transition: Transition.noTransition,
    ),
    GetPage(
      name: POST,
      page: () => PostCreateScreen(),
      binding: PostBinding(),
      transition: Transition.noTransition,
    ),
    GetPage(name: CHAT, page: () => SplashScreen(), binding: ChatBinding()),
    GetPage(
      name: AppRoutes.POST_DETAIL,
      page: () => PostDetailScreen(),
      binding: PostDetailBinding(),
      transition: Transition.noTransition,
    ),
    GetPage(
      name: AppRoutes.CHAT_ROOM,
      page: () {
        // 💡 Get.toNamed에서 보낸 arguments를 여기서 꺼냅니다.
        final args = Get.arguments as Map<String, dynamic>;
        return ChatScreen(roomId: args['roomId'], roomName: args['roomName']);
      },
      binding: ChatRoomBinding(),
      transition: Transition.noTransition,
    ),
    GetPage(
      name: AppRoutes.CHAT_LIST,
      page: () => ChatListScreen(),
      binding: ChatBinding(),
      transition: Transition.noTransition,
    ),
    GetPage(
      name: AppRoutes.POST_DETAIL,
      page: () => PostDetailScreen(),
      binding: PostDetailBinding(),
      transition: Transition.noTransition,
    ),
    GetPage(
      name: FRIDGE,
      page: () => FridgeListScreen(),
      binding: FridgeBinding(),
      /* 👈 여기서 바인딩을 연결합니다. */ transition: Transition.noTransition,
    ),
    GetPage(
      name: FRIDGE_ADD,
      page: () => const FridgeAddStepScreen(),
      binding: FridgeBinding(),
      /* 같은 바인딩 사용 (서비스/컨트롤러 공유) */ transition:
          Transition.cupertino /* 추가 화면은 슬라이드 효과 권장 */,
    ),
  ];
}
