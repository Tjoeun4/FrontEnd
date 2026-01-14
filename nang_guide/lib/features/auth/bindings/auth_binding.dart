import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../controllers/auth_controller.dart';
import '../services/auth_api_client.dart';
import '../services/google_auth_service.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    // Services
    Get.put(GetStorage(), permanent: true); // Initialize GetStorage
    Get.put<GoogleAuthService>(GoogleAuthService(), permanent: true);
    Get.put<AuthApiClient>(AuthApiClient(), permanent: true);

    // Controllers
    Get.put<AuthController>(AuthController(), permanent: true);
    // Get.put(NavController(), permanent: true); // NavController might be related to overall app navigation, not directly auth, so I'm commenting it for now.
  }
}
