import 'package:flutex_admin/common/components/card/glass_card.dart';
import 'package:flutex_admin/core/helper/security_controller.dart';
import 'package:flutex_admin/core/utils/color_resources.dart';
import 'package:flutex_admin/core/utils/style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppLockScreen extends StatefulWidget {
  const AppLockScreen({super.key});

  @override
  State<AppLockScreen> createState() => _AppLockScreenState();
}

class _AppLockScreenState extends State<AppLockScreen> {
  final List<String> _pin = [];
  final String _correctPin = '1234'; // Mock PIN

  void _onDigitPress(String digit) {
    if (_pin.length < 4) {
      setState(() {
        _pin.add(digit);
      });
      if (_pin.length == 4) {
        _verifyPin();
      }
    }
  }

  void _verifyPin() {
    if (_pin.join() == _correctPin) {
      Get.find<SecurityController>().unlockApp();
      Get.back();
    } else {
      setState(() {
        _pin.clear();
      });
      Get.snackbar('Error', 'Incorrect PIN', backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [ColorResources.gradientStart, ColorResources.gradientEnd],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_person_rounded, size: 80, color: Colors.white),
            const SizedBox(height: 20),
            Text('App Locked', style: semiBoldOverLarge.copyWith(color: Colors.white)),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (index) {
                return Container(
                  margin: const EdgeInsets.all(10),
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: index < _pin.length ? Colors.white : Colors.white24,
                    border: Border.all(color: Colors.white),
                  ),
                );
              }),
            ),
            const SizedBox(height: 40),
            _buildKeypad(),
          ],
        ),
      ),
    );
  }

  Widget _buildKeypad() {
    return Wrap(
      spacing: 20,
      runSpacing: 20,
      alignment: WrapAlignment.center,
      children: [
        for (var i = 1; i <= 9; i++) _buildKey(i.toString()),
        _buildKey('Bio', isBio: true),
        _buildKey('0'),
        _buildKey('Del', isDel: true),
      ],
    );
  }

  Widget _buildKey(String text, {bool isBio = false, bool isDel = false}) {
    return InkWell(
      onTap: () {
        if (isBio) {
          Get.find<SecurityController>().authenticate().then((auth) {
            if (auth) Get.back();
          });
        } else if (isDel) {
          if (_pin.isNotEmpty) setState(() => _pin.removeLast());
        } else {
          _onDigitPress(text);
        }
      },
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: 0.1),
        ),
        alignment: Alignment.center,
        child: isBio 
          ? const Icon(Icons.fingerprint, color: Colors.white)
          : isDel 
            ? const Icon(Icons.backspace, color: Colors.white)
            : Text(text, style: semiBoldOverLarge.copyWith(color: Colors.white)),
      ),
    );
  }
}
