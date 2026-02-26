import 'package:get/get.dart';
import 'package:flutex_admin/features/spanco/controller/spanco_controller.dart';

import 'package:flutex_admin/features/spanco/suspecting/repo/suspecting_repo.dart';
import 'package:flutex_admin/features/spanco/suspecting/controller/suspecting_controller.dart';

import 'package:flutex_admin/features/spanco/prospecting/repo/prospecting_repo.dart';
import 'package:flutex_admin/features/spanco/prospecting/controller/prospecting_controller.dart';

import 'package:flutex_admin/features/spanco/approaching/repo/approaching_repo.dart';
import 'package:flutex_admin/features/spanco/approaching/controller/approaching_controller.dart';

import 'package:flutex_admin/features/spanco/negotiating/repo/negotiating_repo.dart';
import 'package:flutex_admin/features/spanco/negotiating/controller/negotiating_controller.dart';

import 'package:flutex_admin/features/spanco/closure/repo/closure_repo.dart';
import 'package:flutex_admin/features/spanco/closure/controller/closure_controller.dart';

import 'package:flutex_admin/features/spanco/order/repo/order_repo.dart';
import 'package:flutex_admin/features/spanco/order/controller/order_controller.dart';

class SpancoBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SpancoController());

    Get.lazyPut(() => SuspectingRepo(apiClient: Get.find()), fenix: true);
    Get.lazyPut(() => SuspectingController(repo: Get.find()), fenix: true);

    Get.lazyPut(() => ProspectingRepo(apiClient: Get.find()), fenix: true);
    Get.lazyPut(() => ProspectingController(repo: Get.find()), fenix: true);

    Get.lazyPut(() => ApproachingRepo(apiClient: Get.find()), fenix: true);
    Get.lazyPut(() => ApproachingController(repo: Get.find()), fenix: true);

    Get.lazyPut(() => NegotiatingRepo(apiClient: Get.find()), fenix: true);
    Get.lazyPut(() => NegotiatingController(repo: Get.find()), fenix: true);

    Get.lazyPut(() => ClosureRepo(apiClient: Get.find()), fenix: true);
    Get.lazyPut(() => ClosureController(repo: Get.find()), fenix: true);

    Get.lazyPut(() => OrderRepo(apiClient: Get.find()), fenix: true);
    Get.lazyPut(() => OrderController(repo: Get.find()), fenix: true);
  }
}
