import 'package:flutex_admin/core/utils/color_resources.dart';
import 'package:flutex_admin/core/utils/dimensions.dart';
import 'package:flutex_admin/core/utils/style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SuccessDialog extends StatelessWidget {
  final String message;
  final VoidCallback onOkPress;

  const SuccessDialog({
    super.key,
    required this.message,
    required this.onOkPress,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(Dimensions.space20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TweenAnimationBuilder(
              duration: const Duration(milliseconds: 600),
              tween: Tween<double>(begin: 0, end: 1),
              builder: (context, double value, child) {
                return Transform.scale(
                  scale: value,
                  child: Container(
                    height: 80,
                    width: 80,
                    decoration: const BoxDecoration(
                      color: ColorResources.colorGreen,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 50,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: Dimensions.space20),
            Text(
              "Submitted!",
              style: boldLarge.copyWith(fontSize: 20),
            ),
            const SizedBox(height: Dimensions.space10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: regularDefault.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: Dimensions.space20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onOkPress,
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorResources.colorGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text("OK"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
