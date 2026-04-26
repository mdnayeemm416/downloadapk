import 'package:adnetwork/config/api_endpoints.dart';
import 'package:adnetwork/core/services/api_client.dart';
import 'package:adnetwork/layers/data/model/notice_model.dart';
import 'package:adnetwork/layers/dto/api_response.dart';

class NoticeRepository {
  final ApiClient _api = ApiClient.instance;

  Future<ApiResponse<NoticeModel>> getNotices() async {
    return _api.get<NoticeModel>(
      ApiEndpoints.notices,
      fromJsonModel: (json) => NoticeModel.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<ApiResponse<NoticeModel>> createNotice(
      String text, String bgColor, String textColor) async {
    return _api.post<NoticeModel>(
      ApiEndpoints.notices,
      body: {
        'text': text,
        'bg_color': bgColor,
        'text_color': textColor,
      },
      fromJsonModel: (json) => NoticeModel.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<ApiResponse<dynamic>> deleteNotice(String id) async {
    return _api.delete<dynamic>(ApiEndpoints.noticeById(id));
  }
}
