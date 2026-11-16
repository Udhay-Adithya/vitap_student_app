import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:vit_ap_student_app/core/common/widget/error_content_view.dart';
import 'package:vit_ap_student_app/core/common/widget/loader.dart';
import 'package:vit_ap_student_app/core/constants/analytics_constants.dart';
import 'package:vit_ap_student_app/core/services/analytics_service.dart';
import 'package:vit_ap_student_app/core/utils/show_snackbar.dart';
import 'package:vit_ap_student_app/features/home/model/pending_payment.dart';
import 'package:vit_ap_student_app/features/home/view/pages/payment_receipts_page.dart';
import 'package:vit_ap_student_app/features/home/view/widgets/payments/pending_payments.dart';
import 'package:vit_ap_student_app/features/home/viewmodel/pending_payments_viewmodel.dart';

class PaymentsPage extends ConsumerStatefulWidget {
  const PaymentsPage({super.key});

  @override
  ConsumerState<PaymentsPage> createState() => _MyExamScheduleState();
}

class _MyExamScheduleState extends ConsumerState<PaymentsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<PendingPayment>? pendingPayments;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: 0);
    ref.read(analyticsServiceProvider).logScreen('PaymentsPage');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      refreshPendingPayments();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> refreshPendingPayments() async {
    await ref
        .read(pendingPaymentsViewModelProvider.notifier)
        .fetchPendingPayments();
    ref.read(analyticsServiceProvider).logEvent(
      AnalyticsEvents.refreshInitiated,
      {AnalyticsParams.dataType: 'pending_payments'},
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(
      pendingPaymentsViewModelProvider.select((val) => val?.isLoading == true),
    );

    ref.listen(pendingPaymentsViewModelProvider, (_, next) {
      next?.when(
        data: (data) {
          setState(() {
            pendingPayments = data;
          });
        },
        loading: () {},
        error: (error, st) {
          showSnackBar(context, error.toString(), SnackBarType.error);
        },
      );
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Payments',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w500),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (builder) => const PaymentReceiptsPage(),
                ),
              );
            },
            icon: const Icon(Iconsax.receipt_copy),
          ),
          IconButton(
            icon: Icon(
              Iconsax.refresh_copy,
              color: Theme.of(context).colorScheme.primary,
            ),
            onPressed: () {
              refreshPendingPayments();
            },
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: isLoading
          ? const Loader()
          : pendingPayments == null
          ? const ErrorContentView(error: 'Pending Payments not found!')
          : RefreshIndicator(
              onRefresh: refreshPendingPayments,
              child: PendingPayments(pendingPayments: pendingPayments!),
            ),
    );
  }
}
