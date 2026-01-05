import 'package:flutex_admin/core/utils/color_resources.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class NeonButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final bool isLoading;

  const NeonButton({
    super.key,
    required this.text,
    required this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        height: 50,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: const LinearGradient(
            colors: [ColorResources.primaryColor, ColorResources.secondaryColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: ColorResources.primaryColor.withValues(alpha: 0.4),
              blurRadius: 15,
              spreadRadius: 1,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                text,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  letterSpacing: 1.2,
                ),
              ),
      ),
    ).animate(target: isLoading ? 0 : 1).shimmer(duration: 2.seconds, color: Colors.white54);
  }
}
