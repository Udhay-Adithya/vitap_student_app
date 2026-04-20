import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:vit_ap_student_app/features/digital_assignment/model/digital_assignment_model.dart';
import 'package:vit_ap_student_app/features/digital_assignment/viewmodel/upload_assignment_viewmodel.dart';

class OtpBottomSheet extends ConsumerStatefulWidget {
  final DigitalAssignment assignment;
  final VoidCallback onCancel;

  const OtpBottomSheet({
    super.key,
    required this.assignment,
    required this.onCancel,
  });

  @override
  ConsumerState<OtpBottomSheet> createState() => _OtpBottomSheetState();
}

class _OtpBottomSheetState extends ConsumerState<OtpBottomSheet> {
  final _otpController = TextEditingController();
  String? _errorMessage;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  void _submit() {
    final otp = _otpController.text.trim();
    if (otp.isEmpty) {
      setState(() => _errorMessage = 'Please enter the OTP');
      return;
    }
    if (otp.length != 6 || int.tryParse(otp) == null) {
      setState(() => _errorMessage = 'OTP must be a 6-digit number');
      return;
    }

    setState(() {
      _errorMessage = null;
      _isSubmitting = true;
    });

    ref
        .read(uploadAssignmentViewModelProvider.notifier)
        .submitOtp(otpEmail: otp);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Listen to upload state inside the sheet for retry handling.
    ref.listen(uploadAssignmentViewModelProvider, (prev, next) {
      next?.when(
        data: (result) {
          // Upload succeeded after OTP – close the sheet.
          // The parent listener will show the success snackbar.
          if (mounted) Navigator.pop(context);
        },
        loading: () {
          if (mounted) setState(() => _isSubmitting = true);
        },
        error: (error, _) {
          if (!mounted) return;
          final msg = error.toString();
          if (msg == 'Incorrect OTP. Please try again.') {
            setState(() {
              _errorMessage = msg;
              _isSubmitting = false;
            });
            _otpController.clear();
          } else {
            // Non-OTP error – close sheet, parent will show snackbar.
            Navigator.pop(context);
          }
        },
      );
    });

    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        top: 8,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            'OTP Verification',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          // Course info summary (mirrors the portal's info table)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest
                  .withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _otpInfoRow('Course', widget.assignment.courseCode, theme),
                _otpInfoRow('Title', widget.assignment.courseTitle, theme),
                _otpInfoRow('Type', widget.assignment.courseType, theme),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // OTP instruction
          Text(
            'Any update to an existing document requires OTP authentication. '
            'Enter the 6-digit OTP sent to your registered email.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),

          // Error message (red, matching portal's red span)
          if (_errorMessage != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Iconsax.close_circle,
                      size: 18, color: theme.colorScheme.error),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onErrorContainer,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],

          // OTP input field
          TextField(
            controller: _otpController,
            keyboardType: TextInputType.number,
            autofocus: true,
            maxLength: 6,
            enabled: !_isSubmitting,
            onChanged: (_) {
              if (_errorMessage != null) {
                setState(() => _errorMessage = null);
              }
            },
            decoration: InputDecoration(
              labelText: 'Enter OTP',
              hintText: '6-digit OTP',
              counterText: '',
              prefixIcon: const Icon(Iconsax.lock),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Cancel + Submit buttons (matching portal's Cancel / Submit)
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _isSubmitting ? null : widget.onCancel,
                  icon: const Icon(Iconsax.close_circle, size: 18),
                  label: const Text('Cancel'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: theme.colorScheme.error,
                    side: BorderSide(
                        color: theme.colorScheme.error.withValues(alpha: 0.5)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: _isSubmitting ? null : _submit,
                  icon: _isSubmitting
                      ? SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: theme.colorScheme.onPrimary,
                          ),
                        )
                      : const Icon(Iconsax.tick_circle, size: 18),
                  label: Text(_isSubmitting ? 'Verifying...' : 'Submit'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _otpInfoRow(String label, String value, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 60,
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
