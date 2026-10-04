import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vit_ap_student_app/core/common/widget/empty_content_view.dart';
import 'package:vit_ap_student_app/core/common/widget/loader.dart';
import 'package:vit_ap_student_app/features/home/model/payment_receipt.dart';
import 'package:vit_ap_student_app/features/home/viewmodel/payment_receipts_viewmodel.dart';

class PaymentReceiptsPage extends ConsumerStatefulWidget {
  const PaymentReceiptsPage({super.key});

  @override
  ConsumerState<PaymentReceiptsPage> createState() =>
      _PaymentReceiptsPageState();
}

class _PaymentReceiptsPageState extends ConsumerState<PaymentReceiptsPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref
          .read(paymentReceiptsViewModelProvider.notifier)
          .fetchPendingPayments();
    });
  }

  @override
  Widget build(BuildContext context) {
    final receiptsState = ref.watch(paymentReceiptsViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Payment Receipts',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w500),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: receiptsState == null
          ? const Center(child: Loader())
          : receiptsState.when(
              loading: () => const Center(child: Loader()),
              error: (err, _) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.redAccent,
                      size: 48,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Something went wrong:\n$err',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () {
                        ref
                            .read(paymentReceiptsViewModelProvider.notifier)
                            .fetchPendingPayments();
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
              data: (receipts) => receipts.isEmpty
                  ? const EmptyContentView(
                      primaryText: 'No payments found',
                      secondaryText: "Seems like you haven't made any yet.",
                    )
                  : RefreshIndicator(
                      onRefresh: () => ref
                          .read(paymentReceiptsViewModelProvider.notifier)
                          .fetchPendingPayments(),
                      child: ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: receipts.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final receipt = receipts[index];
                          return _PaymentReceiptCard(receipt: receipt);
                        },
                      ),
                    ),
            ),
    );
  }
}

class _PaymentReceiptCard extends StatelessWidget {
  const _PaymentReceiptCard({required this.receipt});

  final PaymentReceipt receipt;

  @override
  Widget build(BuildContext context) {
    final isPaid = receipt.paymentStatus.toLowerCase().contains('paid');

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Receipt #${receipt.receiptNumber}',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                const SizedBox(width: 6),
                Text(receipt.date),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '₹${receipt.amount}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade700,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isPaid ? Colors.green.shade100 : Colors.red.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    receipt.paymentStatus,
                    style: TextStyle(
                      color: isPaid
                          ? Colors.green.shade800
                          : Colors.red.shade800,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
