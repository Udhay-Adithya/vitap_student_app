// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:json_annotation/json_annotation.dart';

part 'credentials.g.dart';

@JsonSerializable()
class Credentials {
  final String registrationNumber;
  final String password;
  final String semSubId;
  final String? wifiUsername;
  final String? wifiPassword;

  Credentials({
    required this.registrationNumber,
    required this.password,
    required this.semSubId,
    this.wifiUsername,
    this.wifiPassword,
  });

  factory Credentials.fromJson(Map<String, dynamic> json) =>
      _$CredentialsFromJson(json);
  Map<String, dynamic> toJson() => _$CredentialsToJson(this);

  Credentials copyWith({
    String? registrationNumber,
    String? password,
    String? semSubId,
    String? wifiUsername,
    String? wifiPassword,
  }) {
    return Credentials(
      registrationNumber: registrationNumber ?? this.registrationNumber,
      password: password ?? this.password,
      semSubId: semSubId ?? this.semSubId,
      wifiUsername: wifiUsername ?? this.wifiUsername,
      wifiPassword: wifiPassword ?? this.wifiPassword,
    );
  }

  @override
  String toString() {
    return 'Credentials(registrationNumber: $registrationNumber, semSubId: $semSubId)';
  }
}
