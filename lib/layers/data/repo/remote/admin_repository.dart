import 'package:adnetwork/config/api_endpoints.dart';
import 'package:adnetwork/core/services/api_client.dart';
import 'package:adnetwork/layers/data/model/user_model.dart';
import 'package:adnetwork/layers/data/model/device_association_model.dart';
import 'package:adnetwork/layers/dto/api_response.dart';

class AdminRepository {
  final ApiClient _api = ApiClient.instance;

  /// GET /admin/users
  Future<ApiResponse<UserModel>> getAllUsers() async {
    return _api.get<UserModel>(
      ApiEndpoints.adminUsers,
      fromJsonModel: (json) =>
          UserModel.fromJson(json as Map<String, dynamic>),
    );
  }

  /// GET /admin/users/pending
  Future<ApiResponse<UserModel>> getPendingApprovals() async {
    return _api.get<UserModel>(
      ApiEndpoints.adminPending,
      fromJsonModel: (json) =>
          UserModel.fromJson(json as Map<String, dynamic>),
    );
  }

  /// PATCH /admin/users/:id/approve
  Future<ApiResponse<UserModel>> approveUser(String userId) async {
    return _api.patch<UserModel>(
      ApiEndpoints.adminApprove(userId),
      fromJsonModel: (json) =>
          UserModel.fromJson(
              (json as Map<String, dynamic>)['user'] as Map<String, dynamic>),
    );
  }

  /// PATCH /admin/users/:id/reject
  Future<ApiResponse<UserModel>> rejectUser(String userId) async {
    return _api.patch<UserModel>(
      ApiEndpoints.adminReject(userId),
      fromJsonModel: (json) =>
          UserModel.fromJson(
              (json as Map<String, dynamic>)['user'] as Map<String, dynamic>),
    );
  }

  /// PATCH /admin/users/:id/block
  Future<ApiResponse<UserModel>> blockUser(String userId) async {
    return _api.patch<UserModel>(
      ApiEndpoints.adminBlock(userId),
      fromJsonModel: (json) =>
          UserModel.fromJson(
              (json as Map<String, dynamic>)['user'] as Map<String, dynamic>),
    );
  }

  /// PATCH /admin/users/:id/unblock
  Future<ApiResponse<UserModel>> unblockUser(String userId) async {
    return _api.patch<UserModel>(
      ApiEndpoints.adminUnblock(userId),
      fromJsonModel: (json) =>
          UserModel.fromJson(
              (json as Map<String, dynamic>)['user'] as Map<String, dynamic>),
    );
  }

  /// PATCH /admin/users/:id/make-admin
  Future<ApiResponse<UserModel>> makeAdmin(String userId) async {
    return _api.patch<UserModel>(
      ApiEndpoints.adminMakeAdmin(userId),
      fromJsonModel: (json) =>
          UserModel.fromJson(
              (json as Map<String, dynamic>)['user'] as Map<String, dynamic>),
    );
  }

  /// PATCH /admin/users/:id/remove-admin
  Future<ApiResponse<UserModel>> removeAdmin(String userId) async {
    return _api.patch<UserModel>(
      ApiEndpoints.adminRemoveAdmin(userId),
      fromJsonModel: (json) => UserModel.fromJson(
          (json as Map<String, dynamic>)['user'] as Map<String, dynamic>),
    );
  }

  /// PATCH /admin/users/:id/make-moderator
  Future<ApiResponse<UserModel>> makeModerator(String userId) async {
    return _api.patch<UserModel>(
      ApiEndpoints.adminMakeModerator(userId),
      fromJsonModel: (json) => UserModel.fromJson(
          (json as Map<String, dynamic>)['user'] as Map<String, dynamic>),
    );
  }

  /// PATCH /admin/users/:id/remove-moderator
  Future<ApiResponse<UserModel>> removeModerator(String userId) async {
    return _api.patch<UserModel>(
      ApiEndpoints.adminRemoveModerator(userId),
      fromJsonModel: (json) => UserModel.fromJson(
          (json as Map<String, dynamic>)['user'] as Map<String, dynamic>),
    );
  }

  /// PATCH /admin/users/:id/reset-password
  Future<ApiResponse<UserModel>> resetPassword(String userId) async {
    return _api.patch<UserModel>(
      ApiEndpoints.adminResetPassword(userId),
      fromJsonModel: (json) => UserModel.fromJson(
          (json as Map<String, dynamic>)['user'] as Map<String, dynamic>),
    );
  }

  /// GET /admin/users/reset-requests
  Future<ApiResponse<UserModel>> getResetRequests({
    int page = 1,
    int limit = 20,
  }) async {
    return _api.get<UserModel>(
      ApiEndpoints.adminResetRequests,
      queryParams: {
        'page': page.toString(),
        'limit': limit.toString(),
      },
      fromJsonModel: (json) => UserModel.fromJson(json as Map<String, dynamic>),
    );
  }

  /// GET /api/admin/devices/pending
  Future<ApiResponse<DeviceAssociationModel>> getPendingDevices({
    int page = 1,
    int limit = 50,
  }) async {
    return _api.get<DeviceAssociationModel>(
      ApiEndpoints.adminPendingDevices,
      queryParams: {
        'page': page.toString(),
        'limit': limit.toString(),
      },
      fromJsonModel: (json) => DeviceAssociationModel.fromJson(
          json as Map<String, dynamic>),
    );
  }

  /// PATCH /admin/users/:id/subscription
  Future<ApiResponse<dynamic>> updateSubscription(String userId, int autolike) async {
    return _api.patch(
      ApiEndpoints.adminUpdateSubscription(userId),
      body: {'autolike': autolike},
    );
  }

  /// PATCH /admin/users/bulk/subscription
  Future<ApiResponse<dynamic>> bulkUpdateSubscription(List<String> userIds, int autolike) async {
    return _api.patch(
      ApiEndpoints.adminBulkUpdateSubscription,
      body: {
        'userIds': userIds,
        'autolike': autolike,
      },
    );
  }

  /// POST /api/admin/devices/approve
  Future<ApiResponse<dynamic>> approveDevice(String userId, String deviceId) async {
    return _api.post<dynamic>(
      ApiEndpoints.adminApproveDevice,
      body: {
        'userId': userId,
        'deviceId': deviceId,
      },
      fromJsonModel: (json) => json,
    );
  }

  /// POST /api/admin/devices/reject
  Future<ApiResponse<dynamic>> rejectDevice(String userId, String deviceId) async {
    return _api.post<dynamic>(
      ApiEndpoints.adminRejectDevice,
      body: {
        'userId': userId,
        'deviceId': deviceId,
      },
      fromJsonModel: (json) => json,
    );
  }
}
