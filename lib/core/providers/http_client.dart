import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'http_client.g.dart';

/// The client for the few requests made from Dart: weather, announcements,
/// the For You feed and GitHub. Everything VTOP goes through the Rust bridge.
@Riverpod(keepAlive: true)
http.Client httpClient(Ref ref) {
  final client = http.Client();
  ref.onDispose(client.close);
  return client;
}
