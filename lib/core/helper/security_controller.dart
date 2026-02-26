import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SecurityController extends GetxController {
  final LocalAuthentication auth = LocalAuthentication();
  final SharedPreferences prefs;

  SecurityController({required this.prefs});

  static const String IS_LOCKED_KEY = 'app_is_locked';
  static const String PIN_KEY = 'app_pin';
  static const String BIOMETRIC_ENABLED_KEY = 'biometric_enabled';

  bool isLocked = false;
  bool isBiometricAvailable = false;

  @override
  void onInit() {
    super.onInit();
    checkBiometrics();
    isLocked = prefs.getBool(IS_LOCKED_KEY) ?? false;
  }

  Future<void> checkBiometrics() async {
    isBiometricAvailable =
        await auth.canCheckBiometrics || await auth.isDeviceSupported();
    update();
  }

  Future<bool> authenticate() async {
    try {
      final bool authenticated = await auth.authenticate(
        localizedReason: 'Authenticate to unlock Flutex Admin',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
      if (authenticated) {
        unlockApp();
      }
      return authenticated;
    } catch (e) {
      return false;
    }
  }

  void lockApp() {
    isLocked = true;
    prefs.setBool(IS_LOCKED_KEY, true);
    update();
  }

  void unlockApp() {
    isLocked = false;
    prefs.setBool(IS_LOCKED_KEY, false);
    update();
  }

  Future<void> setPin(String pin) async {
    await prefs.setString(PIN_KEY, pin);
  }

  bool verifyPin(String pin) {
    return prefs.getString(PIN_KEY) == pin;
  }
}
