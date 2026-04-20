import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vit_ap_student_app/core/common/widget/loader.dart';
import 'package:vit_ap_student_app/core/services/vtop_service.dart';
import 'package:vit_ap_student_app/core/utils/show_snackbar.dart';
import 'package:vit_ap_student_app/features/auth/viewmodel/login_otp_viewmodel.dart';
import 'package:vit_ap_student_app/init_dependencies.dart';

Future<void> showLoginOtpBottomSheet({
  required BuildContext context,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isDismissible: false,
    enableDrag: false,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => const _LoginOtpSheet(),
  );
}

class _LoginOtpSheet extends ConsumerStatefulWidget {
  const _LoginOtpSheet();

  @override
  ConsumerState<_LoginOtpSheet> createState() => _LoginOtpSheetState();
}

class _LoginOtpSheetState extends ConsumerState<_LoginOtpSheet> {
  final _otpController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    await ref
        .read(loginOtpViewModelProvider.notifier)
        .submitOtp(_otpController.text.trim());
  }

  Future<void> _resend() async {
    await ref.read(loginOtpViewModelProvider.notifier).resendOtp();
    if (mounted) {
      showSnackBar(context, 'OTP resent to your email', SnackBarType.success);
    }
  }

  void _cancel() {
    serviceLocator<VtopClientService>().cancelOtp();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final otpState = ref.watch(loginOtpViewModelProvider);
    final isLoading = otpState?.isLoading == true;

    ref.listen(loginOtpViewModelProvider, (previous, next) {
      if (next == null) return;
      next.whenOrNull(
        data: (_) {
          // OTP verified — close sheet. The original operation resumes
          // automatically via the Completer in VtopClientService.
          Navigator.of(context).pop();
        },
        error: (error, _) {
          showSnackBar(context, error.toString(), SnackBarType.error);
        },
      );
    });

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _cancel();
      },
      child: Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'OTP Verification',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'An OTP has been sent to your registered email. '
                'Please enter it below to continue.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                autofocus: true,
                enabled: !isLoading,
                decoration: InputDecoration(
                  labelText: 'Enter OTP',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(9),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter the OTP';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: isLoading ? null : _resend,
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(9),
                        ),
                      ),
                      child: const Text('Resend OTP'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Theme.of(context).colorScheme.secondaryContainer,
                        minimumSize: const Size.fromHeight(48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(9),
                        ),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: Loader(),
                            )
                          : const Text('Verify'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Center(
                child: TextButton(
                  onPressed: isLoading ? null : _cancel,
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
