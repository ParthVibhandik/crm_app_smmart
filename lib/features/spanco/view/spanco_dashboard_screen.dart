import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutex_admin/core/utils/dimensions.dart';
import 'package:flutex_admin/core/utils/style.dart';
import 'package:flutex_admin/common/components/custom_loader/custom_loader.dart';
import 'package:flutex_admin/features/spanco/controller/spanco_controller.dart';

class SpancoDashboardScreen extends StatelessWidget {
  const SpancoDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Spanco Dashboard',
            style: regularLarge.copyWith(color: Colors.white)),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: GetBuilder<SpancoController>(builder: (controller) {
        if (controller.isLoading) {
          return const CustomLoader();
        }
        return RefreshIndicator(
          onRefresh: () async {
            await controller.loadData();
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(Dimensions.space15),
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: Dimensions.space10),
                // Text(
                //   'Select a Stage',
                //   style: semiBoldLarge.copyWith(
                //     color: Theme.of(context).textTheme.bodyLarge?.color,
                //   ),
                //   textAlign: TextAlign.center,
                // ),
                const SizedBox(height: Dimensions.space20),
                _buildStageButton(context, 'Suspecting', Icons.search_rounded,
                    Colors.purple, () => controller.onStageTap('Suspecting')),
                const SizedBox(height: Dimensions.space15),
                _buildStageButton(
                    context,
                    'Prospecting',
                    Icons.person_search_rounded,
                    Colors.blue,
                    () => controller.onStageTap('Prospecting')),
                const SizedBox(height: Dimensions.space15),
                _buildStageButton(
                    context,
                    'Approaching',
                    Icons.chat_bubble_outline_rounded,
                    Colors.teal,
                    () => controller.onStageTap('Approaching')),
                const SizedBox(height: Dimensions.space15),
                _buildStageButton(
                    context,
                    'Negotiating',
                    Icons.handshake_rounded,
                    Colors.orange,
                    () => controller.onStageTap('Negotiating')),
                const SizedBox(height: Dimensions.space15),
                _buildStageButton(
                    context,
                    'Closure',
                    Icons.check_circle_outline_rounded,
                    Colors.green,
                    () => controller.onStageTap('Closure')),
                const SizedBox(height: Dimensions.space15),
                _buildStageButton(
                    context,
                    'Order',
                    Icons.shopping_cart_outlined,
                    Colors.redAccent,
                    () => controller.onStageTap('Order')),
                const SizedBox(height: Dimensions.space20),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildStageButton(BuildContext context, String title, IconData icon,
      Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(Dimensions.space20),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: Dimensions.space20),
            Expanded(
              child: Text(
                title,
                style: semiBoldLarge.copyWith(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  fontSize: 18,
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded,
                color: Colors.grey.shade400, size: 18),
          ],
        ),
      ),
    );
  }
}
