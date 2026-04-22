import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pinput/pinput.dart';
import 'package:vit_ap_student_app/core/common/widget/loader.dart';
import 'package:vit_ap_student_app/core/services/vtop_service.dart';
import 'package:vit_ap_student_app/features/auth/viewmodel/login_otp_viewmodel.dart';
import 'package:vit_ap_student_app/init_dependencies.dart';

Future<void> showLoginOtpBottomSheet({required BuildContext context}) {
  return showModalBottomSheet<void>(
    context: context,
    isDismissible: false,
    enableDrag: false,
    isScrollControlled: true,
    builder: (context) => const _LoginOtpSheet(),
  );
}

class _LoginOtpSheet extends ConsumerStatefulWidget {
  const _LoginOtpSheet();

  @override
  ConsumerState<_LoginOtpSheet> createState() => _LoginOtpSheetState();
}

class _LoginOtpSheetState extends ConsumerState<_LoginOtpSheet> {
  final _pinController = TextEditingController();
  final _focusNode = FocusNode();
  String? _errorMessage;
  bool _resendSuccess = false;

  @override
  void dispose() {
    _pinController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final pin = _pinController.text.trim();
    if (pin.length != 6) {
      setState(() => _errorMessage = 'Please enter a 6-digit OTP');
      return;
    }
    setState(() => _errorMessage = null);
    await ref.read(loginOtpViewModelProvider.notifier).submitOtp(pin);
  }

  Future<void> _resend() async {
    setState(() {
      _errorMessage = null;
      _resendSuccess = false;
    });
    final response = await ref.read(loginOtpViewModelProvider.notifier).resendOtp();
    if (mounted && response) {
      setState(() => _resendSuccess = true);
    }
  }

  Future<void> _cancel() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel verification?'),
        content: const Text(
          'If you cancel, the current operation will fail '
          'and you will need to try again.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Stay'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      serviceLocator<VtopClientService>().cancelOtp();
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
          if (mounted) {
            _pinController.clear();
            setState(() {
              _errorMessage = error.toString();
              _resendSuccess = false;
            });
            _focusNode.requestFocus();
          }
        },
      );
    });

    final defaultPinTheme = const PinTheme(
      width: 60,
      height: 64,
      textStyle: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
    );

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _cancel();
      },
      child: Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'OTP Verification',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'An OTP has been sent to your registered email. '
              'Please enter it below to continue.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            if (_resendSuccess) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryFixedDim,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      size: 18,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'OTP resent to your email',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
            Center(
              child: Container(
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Pinput(
                  controller: _pinController,
                  focusNode: _focusNode,
                  length: 6,
                  autofocus: true,
                  enabled: !isLoading,
                  forceErrorState: _errorMessage != null,
                  errorText: _errorMessage,
                  defaultPinTheme: defaultPinTheme,
                  errorBuilder: (errorText, pin) {
                    if (errorText == null || errorText.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    return Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainerLow,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Text(
                                errorText,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.error,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                  separatorBuilder: (index) => Container(
                    height: 64,
                    width: 1,
                    color: theme.colorScheme.surface,
                  ),
                  focusedPinTheme: defaultPinTheme.copyWith(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.secondaryContainer,
                    ),
                  ),
                  errorPinTheme: defaultPinTheme.copyWith(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainer,
                    ),
                  ),
                  onChanged: (_) {
                    if (_errorMessage != null) {
                      setState(() => _errorMessage = null);
                    }
                  },
                ),
              ),
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
                      backgroundColor: theme.colorScheme.secondaryContainer,
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(9),
                      ),
                    ),
                    child: isLoading
                        ? const SizedBox(width: 24, height: 24, child: Loader())
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
    );
  }
}
