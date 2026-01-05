import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutex_admin/core/utils/color_resources.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'attendance_service.dart';
import 'attendance_status.dart';
import 'package:flutex_admin/core/route/route.dart';
import 'package:flutex_admin/common/components/custom_loader/custom_loader.dart';

// Modern animated attendance screen
class AttendanceScreen extends StatefulWidget {
  final String authToken;

  const AttendanceScreen({super.key, required this.authToken});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> with SingleTickerProviderStateMixin {
  late AttendanceService service;
  AttendanceStatus? status;
  bool loading = true;
  String? error;
  
  // Clock Timer
  late Timer _timer;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  
  String _currentTime = '';
  String _currentDate = '';

  @override
  void initState() {
    super.initState();
    service = AttendanceService(widget.authToken);
    _startClock();
    
    // Breathing animation for the main button
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    loadStatus();
  }
  
  void _startClock() {
    _updateTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateTime();
    });
  }

  void _updateTime() {
    if (!mounted) return;
    final now = DateTime.now();
    setState(() {
      _currentTime = DateFormat('hh:mm a').format(now);
      _currentDate = DateFormat('EEEE, d MMMM').format(now);
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> loadStatus() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      status = await service.getTodayStatus();
    } catch (e) {
      error = e.toString();
    }

    if (mounted) {
      setState(() => loading = false);
    }
  }

  Future<void> punchIn() async {
    setState(() => loading = true);
    try {
      await service.punchIn();
      await loadStatus();
    } catch (e) {
      setState(() => loading = false);
      if (mounted) {
        Get.snackbar('Error', 'Punch In Failed: $e', 
          backgroundColor: Colors.red, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
      }
    }
  }

  Future<void> punchOut() async {
    setState(() => loading = true);
    try {
      final needsReason = await service.requiresGpsOffReason();
      String? reason;

      if (needsReason) {
        reason = await _askGpsReason();
        if (reason == null || reason.isEmpty) {
          setState(() => loading = false);
          return;
        }
      }

      await service.punchOut(gpsOffReason: reason);
      Get.offAllNamed(RouteHelper.dcrScreen);
    } catch (e) {
      setState(() => loading = false);
       if (mounted) {
        Get.snackbar('Error', 'Punch Out Failed: $e', 
          backgroundColor: Colors.red, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
      }
    }
  }

  Future<String?> _askGpsReason() async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('GPS was off'),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: TextField(
            controller: controller,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Enter reason to continue punch-out',
              filled: true,
              fillColor: Theme.of(context).cardColor,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(null),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(controller.text.trim()),
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorResources.primaryColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Submit', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  String _calculateDuration() {
    if (status == null || !status!.punchedIn || status!.punchInTime == null || status!.punchInTime == '--:--') {
      return '--:--';
    }

    try {
      final parts = status!.punchInTime!.split(':');
      if (parts.length != 2) return '--:--';

      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);

      final now = DateTime.now();
      final punchIn = DateTime(now.year, now.month, now.day, hour, minute);
      
      final diff = now.difference(punchIn);
      if (diff.isNegative) return '00:00';

      final h = diff.inHours.toString().padLeft(2, '0');
      final m = (diff.inMinutes % 60).toString().padLeft(2, '0');
      final s = (diff.inSeconds % 60).toString().padLeft(2, '0');
      
      return '$h:$m:$s';
    } catch (e) {
      return '--:--';
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Attendance'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
            onPressed: () => Get.back(),
          ),
        ),
      ),
      body: loading && status == null
          ? Container(
              color: ColorResources.primaryColor,
              child: const Center(child: CustomLoader(isFullScreen: false)),
            )
          : Stack(
              children: [
                // Background Gradient
                Container(
                  height: MediaQuery.of(context).size.height * 0.55,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        ColorResources.primaryColor,
                        ColorResources.secondaryColor,
                      ],
                    ),
                  ),
                ),
                
                // Clock & Date Content
                SafeArea(
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      Text(
                        _currentTime,
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 2,
                        ),
                      ),
                      Text(
                        _currentDate,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withValues(alpha: 0.9),
                          letterSpacing: 1,
                        ),
                      ),
                      
                      const Spacer(),
                      
                      // Bottom Sheet / Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                        decoration: BoxDecoration(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(32),
                            topRight: Radius.circular(32),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 20,
                              offset: const Offset(0, -5),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (error != null)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 20),
                                child: Text(error!, style: const TextStyle(color: Colors.red)),
                              ),

                            // MAIN PULSE BUTTON
                            if (status != null && !(status!.punchedIn && status!.punchedOut))
                              ScaleTransition(
                                scale: _pulseAnimation,
                                child: GestureDetector(
                                  onTap: loading ? null : (status!.punchedIn ? punchOut : punchIn),
                                  child: Container(
                                    width: 180,
                                    height: 180,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: status!.punchedIn
                                            ? [ColorResources.redColor, const Color(0xFF991B1B)]
                                            : [ColorResources.greenColor, const Color(0xFF047857)],
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: (status!.punchedIn ? ColorResources.redColor : ColorResources.greenColor).withValues(alpha: 0.4),
                                          blurRadius: 30,
                                          spreadRadius: 8,
                                          offset: const Offset(0, 10),
                                        ),
                                        BoxShadow(
                                          color: Colors.white.withValues(alpha: 0.2),
                                          blurRadius: 5,
                                          offset: const Offset(-5, -5),
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: loading
                                          ? const CircularProgressIndicator(color: Colors.white)
                                          : Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  status!.punchedIn ? Icons.stop_rounded : Icons.fingerprint_rounded,
                                                  size: 56,
                                                  color: Colors.white,
                                                ),
                                                const SizedBox(height: 10),
                                                Text(
                                                  status!.punchedIn ? 'STOP' : 'START',
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 22,
                                                    fontWeight: FontWeight.w900,
                                                    letterSpacing: 1.5,
                                                  ),
                                                ),
                                              ],
                                            ),
                                    ),
                                  ),
                                ),
                              ),

                            // COMPLETED STATE
                            if (status != null && status!.punchedIn && status!.punchedOut)
                              Container(
                                width: 150,
                                height: 150,
                                decoration: BoxDecoration(
                                  color: ColorResources.greenColor.withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: ColorResources.greenColor, width: 2),
                                ),
                                child: const Center(
                                  child: Icon(Icons.check_rounded, size: 80, color: ColorResources.greenColor),
                                ),
                              ),
                             
                            if (status != null && status!.punchedIn && status!.punchedOut)
                               const Padding(
                                 padding: EdgeInsets.only(top: 20.0),
                                 child: Text(
                                   "Shift Completed",
                                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                 ),
                               ),

                            const SizedBox(height: 40),

                            // INFO ROW
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                              decoration: BoxDecoration(
                                color: isDarkMode ? ColorResources.cardColorDark : Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.5)),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.03),
                                    blurRadius: 10,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  _buildStatusItem(
                                    context,
                                    'Check In',
                                    status?.punchInTime ?? '--:--',
                                    Icons.login_rounded,
                                    ColorResources.blueColor,
                                  ),
                                  Container(height: 40, width: 1, color: Theme.of(context).dividerColor),
                                  _buildStatusItem(
                                    context,
                                    'Total Time',
                                    _calculateDuration(),
                                    status?.punchedIn == true ? Icons.timer_outlined : Icons.timer_off_outlined,
                                    status?.punchedIn == true ? ColorResources.greenColor : ColorResources.yellowColor,
                                  ),
                                ],
                              ),
                            ),
                             const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildStatusItem(BuildContext context, String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 12),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).textTheme.bodySmall?.color,
          ),
        ),
      ],
    );
  }
}
