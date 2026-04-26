import 'package:adnetwork/layers/data/model/user_model.dart';

/// Wraps the login API response: `{ user: {...}, token: "jwt..." }`
class LoginResponseModel {
  final UserModel? user;
  final String? token;

  LoginResponseModel({this.user, this.token});

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
      user: json['user'] != null
          ? UserModel.fromJson(json['user'] as Map<String, dynamic>)
          : null,
      token: json['token'] as String?,
    );
  }
}
