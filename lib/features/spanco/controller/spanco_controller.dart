import 'package:flutex_admin/features/spanco/suspecting/view/suspecting_list_screen.dart';
import 'package:flutex_admin/features/spanco/prospecting/view/prospecting_list_screen.dart';
import 'package:flutex_admin/features/spanco/approaching/view/approaching_list_screen.dart';
import 'package:flutex_admin/features/spanco/negotiating/view/negotiating_list_screen.dart';
import 'package:flutex_admin/features/spanco/closure/view/closure_list_screen.dart';
import 'package:flutex_admin/features/spanco/order/view/order_list_screen.dart';
import 'package:get/get.dart';

class SpancoController extends GetxController {
  bool isLoading = false;

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  Future<void> loadData() async {
    isLoading = true;
    update();

    await Future.delayed(const Duration(milliseconds: 500));

    isLoading = false;
    update();
  }

  void onStageTap(String stage) {
    if (stage == 'Suspecting') {
      Get.to(() => const SuspectingListScreen());
    } else if (stage == 'Prospecting') {
      Get.to(() => const ProspectingListScreen());
    } else if (stage == 'Approaching') {
      Get.to(() => const ApproachingListScreen());
    } else if (stage == 'Negotiating') {
      Get.to(() => const NegotiatingListScreen());
    } else if (stage == 'Closure') {
      Get.to(() => const ClosureListScreen());
    } else if (stage == 'Order') {
      Get.to(() => const OrderListScreen());
    }
  }
}
