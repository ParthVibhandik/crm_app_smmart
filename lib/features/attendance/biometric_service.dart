import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';

class BiometricService {
  final LocalAuthentication _auth = LocalAuthentication();

  Future<bool> isBiometricAvailable() async {
    try {
      final canCheck = await _auth.canCheckBiometrics;
      final isSupported = await _auth.isDeviceSupported();
      
      print('BiometricService: canCheckBiometrics=$canCheck, isDeviceSupported=$isSupported');
      
      if (!canCheck || !isSupported) {
        return false;
      }

      // Get available biometric types
      final availableBiometrics = await _auth.getAvailableBiometrics();
      print('BiometricService: Available biometrics: $availableBiometrics');
      
      return availableBiometrics.isNotEmpty;
    } on PlatformException catch (e) {
      print('BiometricService: Error checking biometric availability: ${e.code} - ${e.message}');
      return false;
    }
  }

  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _auth.getAvailableBiometrics();
    } on PlatformException catch (e) {
      print('BiometricService: Error getting available biometrics: ${e.code} - ${e.message}');
      return [];
    }
  }

  Future<bool> authenticate(String reason) async {
    try {
      print('BiometricService: Starting authentication...');
      
      // First check if biometrics are available
      if (!await isBiometricAvailable()) {
        print('BiometricService: Biometrics not available on this device');
        return false;
      }

      final result = await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
      
      print('BiometricService: Authentication result: $result');
      return result;
    } on PlatformException catch (e) {
      print('BiometricService: Authentication error: ${e.code} - ${e.message}');
      
      // Handle specific error codes
      switch (e.code) {
        case 'NotAvailable':
          print('BiometricService: Biometric authentication is not available on this device');
          break;
        case 'NotEnrolled':
          print('BiometricService: No biometrics are enrolled on this device');
          break;
        case 'PasscodeNotSet':
          print('BiometricService: No passcode is set on this device');
          break;
        case 'UserCancel':
          print('BiometricService: User cancelled biometric authentication');
          break;
        case 'UserFallback':
          print('BiometricService: User selected fallback authentication method');
          break;
        case 'SystemCancel':
          print('BiometricService: System cancelled biometric authentication');
          break;
        case 'InvalidContext':
          print('BiometricService: Invalid context for biometric authentication');
          break;
        default:
          print('BiometricService: Unknown error: ${e.code}');
      }
      
      return false;
    } catch (e) {
      print('BiometricService: Unexpected error: $e');
      return false;
    }
  }
}
