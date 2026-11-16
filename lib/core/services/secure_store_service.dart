import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vit_ap_student_app/core/error/exceptions.dart';
import 'package:vit_ap_student_app/core/models/credentials.dart';

part 'secure_store_service.g.dart';

@Riverpod(keepAlive: true)
SecureStorageService secureStorageService(Ref ref) =>
    SecureStorageService(const FlutterSecureStorage());

class SecureStorageService {
  static const String _userCredentialsKey = 'stu_credentials';
  final FlutterSecureStorage _storage;

  SecureStorageService(this._storage);

  Future<void> saveCredentials(Credentials credentials) async {
    try {
      await _storage.write(
        key: _userCredentialsKey,
        value: jsonEncode(credentials.toJson()),
      );
    } catch (e) {
      throw SecureStorageException('Failed to save credentials: $e');
    }
  }

  Future<Credentials?> getCredentials() async {
    try {
      final jsonString = await _storage.read(key: _userCredentialsKey);
      if (jsonString == null) return null;
      return Credentials.fromJson(
        jsonDecode(jsonString) as Map<String, dynamic>,
      );
    } catch (e) {
      throw SecureStorageException('Failed to read credentials: $e');
    }
  }

  Future<void> clearCredentials() async {
    try {
      await _storage.delete(key: _userCredentialsKey);
    } catch (e) {
      throw SecureStorageException('Failed to clear credentials: $e');
    }
  }
}
