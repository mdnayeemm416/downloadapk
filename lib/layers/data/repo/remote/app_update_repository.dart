import 'package:adnetwork/config/api_endpoints.dart';
import 'package:adnetwork/core/services/api_client.dart';
import 'package:adnetwork/layers/dto/api_response.dart';
import 'package:adnetwork/core/models/app_update_model.dart';

class AppUpdateRepository {
  final ApiClient _api = ApiClient.instance;

  Future<ApiResponse<AppUpdateModel>> checkUpdate(String appName) async {
    return _api.get<AppUpdateModel>(
      ApiEndpoints.appUpdates,
      queryParams: {'appname': appName},
      fromJsonModel: (json) =>
          AppUpdateModel.fromJson(json as Map<String, dynamic>),
      auth: false,
    );
  }
}
