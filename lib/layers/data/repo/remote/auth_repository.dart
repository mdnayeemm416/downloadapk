import 'package:adnetwork/config/api_endpoints.dart';
import 'package:adnetwork/core/services/api_client.dart';
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

    return _api.post(
      ApiEndpoints.register,
      body: {
        'first_name': firstName,
        'last_name': lastName,
        'username': username,
        'email': email,
        'password': password,
        'currentAppVersion': version,
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

    return _api.post<LoginResponseModel>(
      ApiEndpoints.login,
      body: {
        'email': email,
        'password': password,
        'currentAppVersion': packageInfo.version,
      },
      fromJsonModel: (json) =>
          LoginResponseModel.fromJson(json as Map<String, dynamic>),
      auth: false,
    );
  }
}
