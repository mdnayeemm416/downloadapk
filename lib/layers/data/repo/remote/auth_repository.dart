import 'package:adnetwork/config/api_endpoints.dart';
import 'package:adnetwork/core/services/api_client.dart';
import 'package:adnetwork/core/services/token_storage.dart';
import 'package:adnetwork/layers/data/model/login_response_model.dart';
import 'package:adnetwork/layers/dto/api_response.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AuthRepository {
  final ApiClient _api = ApiClient.instance;

  /// POST /auth/register
  Future<ApiResponse<dynamic>> register({
    required String firstName,
    required String lastName,
    required String username,
    required String email,
    required String password,
    String? gender,
  }) async {
    final packageInfo = await PackageInfo.fromPlatform();
    final version = "${packageInfo.version}+${packageInfo.buildNumber}";
    final deviceId = await TokenStorage.instance.getOrGenerateDeviceId();

    return _api.post(
      ApiEndpoints.register,
      body: {
        'first_name': firstName,
        'last_name': lastName,
        'username': username,
        'email': email,
        'appname': 'adnetworkpro',
        'password': password,
        'currentAppVersion': version,
        'deviceId': deviceId,
        if (gender != null) 'gender': gender,
      },
      auth: false,
    );
  }

  /// POST /auth/login
  Future<ApiResponse<LoginResponseModel>> login({
    required String email,
    required String password,
  }) async {
    final packageInfo = await PackageInfo.fromPlatform();
    final deviceId = await TokenStorage.instance.getOrGenerateDeviceId();

    return _api.post<LoginResponseModel>(
      ApiEndpoints.login,
      body: {
        'email': email,
        'password': password,
        'appname': 'adnetworkpro',
        'currentAppVersion': packageInfo.version,
        'deviceId': deviceId,
      },
      fromJsonModel: (json) =>
          LoginResponseModel.fromJson(json as Map<String, dynamic>),
      auth: false,
    );
  }

  /// POST /auth/forgot-password
  Future<ApiResponse<dynamic>> forgotPassword({
    required String identifier,
    required String newPassword,
  }) async {
    return _api.post(
      ApiEndpoints.forgotPassword,
      body: {
        'identifier': identifier,
        'appname': 'adnetworkpro',
        'newPassword': newPassword,
      },
      auth: false,
    );
  }

  /// GET /subscriptions/check
  Future<ApiResponse<dynamic>> checkSubscription(String username) async {
    return _api.get(
      '${ApiEndpoints.checkSubscription}?username=$username&appname=adnetworkpro',
      auth: false,
    );
  }
}
