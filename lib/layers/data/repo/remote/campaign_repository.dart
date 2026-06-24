import 'package:adnetwork/core/services/api_client.dart';
import 'package:adnetwork/layers/data/model/campaign_link_model.dart';
import 'package:adnetwork/layers/data/model/campaign_status_model.dart';
import 'package:adnetwork/layers/dto/api_response.dart';

class CampaignRepository {
  final ApiClient _api = ApiClient.instance;

  /// GET /api/campaigns
  Future<ApiResponse<CampaignLinkModel>> getCampaignFeed() async {
    return _api.get<CampaignLinkModel>(
      '/api/campaigns',
      fromJsonModel: (json) => CampaignLinkModel.fromJson(json as Map<String, dynamic>),
    );
  }

  /// GET /api/campaigns/status
  Future<ApiResponse<CampaignStatusModel>> getCampaignStatus() async {
    return _api.get<CampaignStatusModel>(
      '/api/campaigns/status',
      fromJsonModel: (json) => CampaignStatusModel.fromJson(json as Map<String, dynamic>),
    );
  }

  /// GET /api/campaigns/links/me
  Future<ApiResponse<CampaignLinkModel>> getMyCampaignLinks() async {
    return _api.get<CampaignLinkModel>(
      '/api/campaigns/links/me',
      fromJsonModel: (json) => CampaignLinkModel.fromJson(json as Map<String, dynamic>),
    );
  }

  /// POST /api/campaigns/links
  Future<ApiResponse<CampaignLinkModel>> createCampaignLink({
    required String url,
    String? title,
    String? description,
  }) async {
    return _api.post<CampaignLinkModel>(
      '/api/campaigns/links',
      body: {
        'url': url,
        if (title != null && title.isNotEmpty) 'title': title,
        if (description != null && description.isNotEmpty) 'description': description,
      },
      fromJsonModel: (json) => CampaignLinkModel.fromJson(json as Map<String, dynamic>),
    );
  }

  /// DELETE /api/campaigns/links/:id
  Future<ApiResponse<dynamic>> deleteCampaignLink(String id) async {
    return _api.delete('/api/campaigns/links/$id');
  }

  /// POST /api/campaigns/links/:id/like
  Future<ApiResponse<dynamic>> likeCampaignLink(String id) async {
    return _retryRequest(() => _api.post('/api/campaigns/links/$id/like'));
  }

  /// POST /api/campaigns/complete
  Future<ApiResponse<int>> completeCampaign() async {
    return _retryRequest(() => _api.post<int>(
      '/api/campaigns/complete',
      fromJsonModel: (json) {
        if (json is Map<String, dynamic>) {
          return json['completed_count'] as int? ?? 0;
        }
        return 0;
      },
    ));
  }

  /// GET /api/campaigns/completions/me
  Future<ApiResponse<int>> getMyCompletions() async {
    return _api.get<int>(
      '/api/campaigns/completions/me',
      fromJsonModel: (json) {
        if (json is Map<String, dynamic>) {
          return json['completed_count'] as int? ?? 0;
        }
        return 0;
      },
    );
  }

  /// Helper to retry requests in case of temporary network disruptions (ClientException)
  Future<ApiResponse<T>> _retryRequest<T>(Future<ApiResponse<T>> Function() request, {int retries = 3}) async {
    int attempts = 0;
    while (attempts < retries) {
      attempts++;
      try {
        final response = await request();
        if (response.isSuccess || attempts >= retries) {
          return response;
        }
      } catch (e) {
        if (attempts >= retries) {
          rethrow;
        }
      }
      // Wait 1 second before retrying to allow network interfaces to settle
      await Future.delayed(const Duration(seconds: 1));
    }
    return ApiResponse<T>(message: 'Failed after $retries retries');
  }
}
