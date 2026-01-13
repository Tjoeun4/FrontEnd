import 'package:get/get.dart';

// 바인딩
import './../bindings/top_nav/alarm_binding.dart';
import './../bindings/auth_binding.dart';
import './../bindings/top_nav/chat_binding.dart';
import './../bindings/bottom_nav/community_binding.dart';
import './../bindings/bottom_nav/ledger_binding.dart';
import './../bindings/login/login_binding.dart';
import './../bindings/post_binding.dart';
import './../bindings/bottom_nav/profile_binding.dart';
import './../bindings/bottom_nav/recommend_binding.dart';
import './../bindings/top_nav/search_binding.dart';
import './../bindings/login/signin_binding.dart';
import './../bindings/login/signup_binding.dart';
import './../bindings/bottom_nav/home_binding.dart';

// 뷰
import './../views/bottom_nav_screen/home_screen.dart';
import './../views/bottom_nav_screen/community_screen.dart';
import './../views/bottom_nav_screen/ledger_screen.dart';
import './../views/bottom_nav_screen/profile_screen.dart';
import './../views/bottom_nav_screen/recommend_screen.dart';
import './../views/email_signup_screen.dart';
import './../views/email_login_screen.dart';
import './../views/splash_screen.dart';
import './../views/login_selection_screen.dart';

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

  static final routes = [
    GetPage(name: SPLASH, page: () => SplashScreen(), binding: AuthBinding()),
    GetPage(name: SIGNUP, page: () => EmailSignUpScreen(), binding: SignupBinding(),transition: Transition.noTransition,),
    GetPage(name: SIGNIN, page: () => EmailLoginScreen(), binding: SigninBinding(),transition: Transition.noTransition,),
    GetPage(
      name: LOGIN,
      page: () => LoginSelectionScreen(),
      binding: LoginBinding(),
      // middlewares: [AuthMiddleware(), OwnerMiddleware()],
      transition: Transition.noTransition,
    ),
    GetPage(name: HOME, page: () => HomeScreen(), binding: HomeBinding(),transition: Transition.noTransition,),
    GetPage(name: SEARCH, page: () => SplashScreen(), binding: SearchBinding()),
    GetPage(name: ALARM, page: () => SplashScreen(), binding: AlarmBinding()),
    GetPage(name: COMMUNITY, page: () => CommunityScreen(), binding: CommunityBinding(),transition: Transition.noTransition,),
    GetPage(name: RECOMMEND, page: () => RecommendScreen(), binding: RecommendBinding(),transition: Transition.noTransition,),
    GetPage(name: LEDGER, page: () => LedgerScreen(), binding: LedgerBinding(),transition: Transition.noTransition,),
    GetPage(name: PROFILE, page: () => ProfileScreen(), binding: ProfileBinding(),transition: Transition.noTransition,),
    GetPage(name: POST, page: () => SplashScreen(), binding: PostBinding()),
    GetPage(name: CHAT, page: () => SplashScreen(), binding: ChatBinding()),
  ];
}
