import 'dart:convert';
import 'package:flutex_admin/common/components/app-bar/custom_appbar.dart';
import 'package:flutex_admin/common/components/snack_bar/show_custom_snackbar.dart';
import 'package:flutex_admin/common/components/text-form-field/custom_text_field.dart';
import 'package:flutex_admin/core/service/api_service.dart';
import 'package:flutex_admin/core/route/route.dart';
import 'package:flutex_admin/features/invoice/model/invoice_model.dart';
import 'package:flutex_admin/features/invoice/repo/invoice_repo.dart';
import 'package:flutex_admin/features/sales_tracker/model/trip_session.dart';
import 'package:flutex_admin/features/sales_tracker/repo/sales_tracker_repo.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EndTripScreen extends StatefulWidget {
  const EndTripScreen({super.key});

  @override
  State<EndTripScreen> createState() => _EndTripScreenState();
}

class _EndTripScreenState extends State<EndTripScreen> {
  late SalesTrackerRepo _salesTrackerRepo;
  late InvoiceRepo _invoiceRepo;
  bool _isSubmitting = false;
  final TextEditingController _callRemarkController = TextEditingController();

  List<Invoice> _invoices = [];
  String? _selectedInvoiceId;
  bool _isLoadingInvoices = false;

  @override
  void initState() {
    super.initState();
    _ensureRepo();
    _ensureInvoiceRepo();
    _loadInvoices();
  }

  @override
  void dispose() {
    _callRemarkController.dispose();
    super.dispose();
  }

  void _ensureRepo() {
    try {
      _salesTrackerRepo = Get.find<SalesTrackerRepo>();
    } catch (_) {
      _salesTrackerRepo = SalesTrackerRepo(apiClient: Get.find<ApiClient>());
      Get.put(_salesTrackerRepo);
    }
  }

  void _ensureInvoiceRepo() {
    if (Get.isRegistered<InvoiceRepo>()) {
      _invoiceRepo = Get.find<InvoiceRepo>();
    } else {
      _invoiceRepo = InvoiceRepo(apiClient: Get.find<ApiClient>());
      // Optionally put it: Get.put(_invoiceRepo);
    }
  }

  Future<void> _loadInvoices() async {
    setState(() => _isLoadingInvoices = true);
    try {
      final response = await _invoiceRepo.getAllInvoices();
      if (response.status) {
        final model = InvoicesModel.fromJson(jsonDecode(response.responseJson));
        if (model.data != null) {
          final now = DateTime.now();
          final todayStr = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
          
          List<Invoice> sortedInvoices = model.data!;
          // Sort by ID descending (newest first)
          sortedInvoices.sort((a, b) {
             return (int.tryParse(b.id ?? '0') ?? 0).compareTo(int.tryParse(a.id ?? '0') ?? 0);
          });
          
          setState(() {
            _invoices = sortedInvoices;
            
            // Auto-select if there is an invoice created today
            try {
              final recentInvoice = _invoices.firstWhere((inv) {
                 bool isToday = inv.date == todayStr || (inv.dateCreated != null && inv.dateCreated!.startsWith(todayStr));
                 return isToday;
              });
              _selectedInvoiceId = recentInvoice.id;
            } catch (_) {
              // No invoice from today found
            }
          });
        }
      }
    } catch (e) {
      print('Error loading invoices: $e');
    } finally {
      if (mounted) setState(() => _isLoadingInvoices = false);
    }
  }

  Widget _primaryButton({
    required String label,
    required VoidCallback? onTap,
    Color? color,
  }) {
    return SizedBox(
      height: 48,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color ?? Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: Text(label),
      ),
    );
  }

  Future<void> _endTrip() async {
    final remark = _callRemarkController.text.trim();
    setState(() => _isSubmitting = true);
    try {
      final response = await _salesTrackerRepo.endTrip(
          callRemark: remark, 
          invoiceId: _selectedInvoiceId
      );
      if (response.status) {
        CustomSnackBar.success(successList: ['Trip ended successfully']);
        // Clear any stored trip session data
        await TripSession.clearActiveTrip();
        // Navigate to dashboard
        Get.offAllNamed(RouteHelper.dashboardScreen);
      } else {
        CustomSnackBar.error(errorList: [response.message.tr]);
      }
    } catch (e) {
      CustomSnackBar.error(errorList: ['Error ending trip: $e']);
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Get.offAllNamed(RouteHelper.dashboardScreen);
        return false;
      },
      child: Scaffold(
        appBar: const CustomAppBar(title: 'End Trip'),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.flag_outlined,
                                size: 28, color: Colors.red),
                            SizedBox(width: 8),
                            Text(
                              'End your trip',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'When you are done with the call, you can end the trip.',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                        const SizedBox(height: 20),
                        
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                icon: const Icon(Icons.description),
                                label: const Text('Proposals'),
                                onPressed: () {
                                  Get.toNamed(RouteHelper.proposalScreen);
                                },
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                icon: const Icon(Icons.receipt),
                                label: const Text('Invoices'),
                                onPressed: () {
                                  Get.toNamed(RouteHelper.invoiceScreen);
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        if (_isLoadingInvoices)
                           const Center(child: LinearProgressIndicator())
                        else if (_invoices.isNotEmpty)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Link Created Invoice (Optional)", style: TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              DropdownButtonFormField<String>(
                                value: _selectedInvoiceId,
                                isExpanded: true,
                                itemHeight: null, // Allow variable height for items
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                hint: const Text("Select Invoice"),
                                items: [
                                  const DropdownMenuItem<String>(
                                    value: null,
                                    child: Text("None (Do not send any invoice)"),
                                  ),
                                  ..._invoices.take(50).map((inv) {
                                     return DropdownMenuItem<String>(
                                       value: inv.id,
                                       child: Padding(
                                         padding: const EdgeInsets.symmetric(vertical: 8.0),
                                         child: Column(
                                           crossAxisAlignment: CrossAxisAlignment.start,
                                           mainAxisSize: MainAxisSize.min,
                                           children: [
                                             Text(
                                               "${inv.prefix ?? ''}${inv.number ?? ''} - ${inv.clientName ?? 'Unknown'}",
                                               style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                                               maxLines: 2,
                                               overflow: TextOverflow.ellipsis,
                                             ),
                                             const SizedBox(height: 2),
                                             Text(
                                               "${inv.total ?? ''} (${inv.date ?? ''})",
                                               style: const TextStyle(fontSize: 12, color: Colors.grey),
                                             ),
                                           ],
                                         ),
                                       ),
                                     );
                                  }),
                                ].toList(),
                                onChanged: (val) {
                                  setState(() {
                                    _selectedInvoiceId = val;
                                  });
                                },
                                selectedItemBuilder: (BuildContext context) {
                                  return [
                                    const Text("None (Do not send any invoice)", overflow: TextOverflow.ellipsis, maxLines: 1),
                                    ..._invoices.take(50).map((inv) {
                                      return Column(
                                         crossAxisAlignment: CrossAxisAlignment.start,
                                         mainAxisAlignment: MainAxisAlignment.center,
                                         mainAxisSize: MainAxisSize.min,
                                         children: [
                                           Text(
                                             "${inv.prefix ?? ''}${inv.number ?? ''} - ${inv.clientName ?? 'Unknown'}",
                                             style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                                             maxLines: 1, 
                                             overflow: TextOverflow.ellipsis,
                                           ),
                                           Text(
                                             "${inv.total ?? ''} (${inv.date ?? ''})",
                                             style: const TextStyle(fontSize: 12, color: Colors.grey),
                                             maxLines: 1,
                                             overflow: TextOverflow.ellipsis,
                                           ),
                                         ],
                                       );
                                    }),
                                  ];
                                },
                              ),
                              const SizedBox(height: 20),
                            ],
                          ),

                        CustomTextField(
                          controller: _callRemarkController,
                          labelText: 'Call Remark',
                          hintText: 'Enter call remark or notes',
                          maxLines: 3,
                          onChanged: (val) {},
                        ),
                        const SizedBox(height: 24),
                        _primaryButton(
                          label: 'End Trip',
                          onTap: _isSubmitting ? null : _endTrip,
                          color: Colors.red,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

