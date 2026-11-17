import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vit_ap_student_app/features/vtop_webview/models/webview_session.dart';
import 'package:vit_ap_student_app/features/vtop_webview/repository/webview_session_repository.dart';

part 'webview_session_viewmodel.g.dart';

/// The VTOP session the WebView continues. Null until [open] is called.
@riverpod
class WebViewSessionViewModel extends _$WebViewSessionViewModel {
  @override
  AsyncValue<WebViewSession>? build() => null;

  Future<void> open() async {
    final repository = ref.read(webViewSessionRepositoryProvider);
    state = const AsyncValue.loading();
    final res = await repository.openSession();
    if (!ref.mounted) return;
    state = switch (res) {
      Left(value: final failure) => AsyncValue.error(
        failure.message,
        StackTrace.current,
      ),
      Right(value: final session) => AsyncValue.data(session),
    };
  }

  /// Starts over with a fresh login, for when the portal rejected the session.
  Future<void> refresh() async {
    ref.read(webViewSessionRepositoryProvider).resetSession();
    await open();
  }
}
