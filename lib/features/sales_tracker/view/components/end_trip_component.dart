import 'dart:convert';
import 'package:flutex_admin/common/components/snack_bar/show_custom_snackbar.dart';
import 'package:flutex_admin/common/components/text-form-field/custom_text_field.dart';
import 'package:flutex_admin/core/route/route.dart';
import 'package:flutex_admin/features/invoice/model/invoice_model.dart';
import 'package:flutex_admin/features/invoice/repo/invoice_repo.dart';
import 'package:flutex_admin/core/service/api_service.dart';
import 'package:flutex_admin/features/sales_tracker/model/trip_session.dart';
import 'package:flutex_admin/features/sales_tracker/repo/sales_tracker_repo.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EndTripComponent extends StatefulWidget {
  final Function(String) onStatusChanged;

  const EndTripComponent({
    super.key,
    required this.onStatusChanged,
  });

  @override
  State<EndTripComponent> createState() => _EndTripComponentState();
}

class _EndTripComponentState extends State<EndTripComponent> {
  late SalesTrackerRepo _repo;
  late InvoiceRepo _invoiceRepo;
  bool _isSubmitting = false;
  final TextEditingController _callRemarkController = TextEditingController();
  
  List<Invoice> _invoices = [];
  String? _selectedInvoiceId;
  bool _isLoadingInvoices = false;

  @override
  void initState() {
    super.initState();
    _repo = Get.find<SalesTrackerRepo>();
    _ensureInvoiceRepo();
    _loadInvoices();
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
            // We check 'date' or 'datecreated' (datecreated often includes time or is YYYY-MM-DD)
            // Ideally we check if it was created within the last few hours (session duration), 
            // but for now, "today" and "top of list" is a good heuristic.
            
            // Let's look for the first invoice that has today's date
            try {
              final recentInvoice = _invoices.firstWhere((inv) {
                 // Check date (YYYY-MM-DD)
                 bool isToday = inv.date == todayStr || (inv.dateCreated != null && inv.dateCreated!.startsWith(todayStr));
                 return isToday;
              });
              _selectedInvoiceId = recentInvoice.id;
            } catch (_) {
              // No invoice from today found, do not auto-select
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
      final response = await _repo.endTrip(
          callRemark: remark, 
          invoiceId: _selectedInvoiceId
      );
      if (response.status) {
        CustomSnackBar.success(successList: ['Trip ended successfully']);
        await TripSession.clearActiveTrip();
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
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.flag_outlined, size: 28, color: Colors.red),
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
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            hint: const Text("Select Invoice"),
                            items: _invoices.take(50).map((inv) {
                               return DropdownMenuItem<String>(
                                 value: inv.id,
                                 child: Text(
                                   "${inv.prefix ?? ''}${inv.number ?? ''} - ${inv.total ?? ''} (${inv.date ?? ''})",
                                   overflow: TextOverflow.ellipsis,
                                   style: const TextStyle(fontSize: 13),
                                 ),
                               );
                            }).toList(),
                            onChanged: (val) {
                              setState(() {
                                _selectedInvoiceId = val;
                              });
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
    );
  }

  @override
  void dispose() {
    _callRemarkController.dispose();
    super.dispose();
  }
}

