import 'dart:convert';
import 'dart:io';

import 'package:adnetwork/config/env_config.dart';
import 'package:adnetwork/core/services/token_storage.dart';
import 'package:adnetwork/layers/dto/api_response.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:pretty_http_logger/pretty_http_logger.dart';

/// Centralized HTTP client that wraps the `http` package.
///
/// • Auto-injects `Authorization: Bearer <token>` for authenticated requests.
/// • Every response is parsed into [ApiResponse<T>].
class ApiClient {
  ApiClient._();
  static final ApiClient instance = ApiClient._();

  final HttpWithMiddleware _client = HttpWithMiddleware.build(middlewares: [
    if (!kReleaseMode) HttpLogger(logLevel: LogLevel.BODY),
  ]);

  // ─────────────────── Helpers ───────────────────

  /// Builds the full URI from an endpoint path.
  Uri _uri(String path, {Map<String, String>? queryParams}) {
    final base = EnvConfig.baseUrl.endsWith('/')
        ? EnvConfig.baseUrl.substring(0, EnvConfig.baseUrl.length - 1)
        : EnvConfig.baseUrl;
    return Uri.parse('$base$path').replace(queryParameters: queryParams);
  }

  /// Returns common headers; includes Bearer token when available.
  Future<Map<String, String>> _headers({bool auth = true}) async {
    final headers = <String, String>{
      HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.acceptHeader: 'application/json',
    };
    if (auth) {
      final token = await TokenStorage.instance.getToken();
      if (token != null && token.isNotEmpty) {
        headers[HttpHeaders.authorizationHeader] = 'Bearer $token';
      }
    }
    return headers;
  }

  /// Parses an [http.Response] into [ApiResponse<T>].
  ApiResponse<T> _parse<T>(
    http.Response response,
    T Function(dynamic json)? fromJsonModel,
  ) {
    try {
      final Map<String, dynamic> body = jsonDecode(response.body);
      return ApiResponse<T>.fromJson(body, fromJsonModel);
    } catch (e) {
      return ApiResponse<T>(
        statusCode: response.statusCode,
        message: 'Failed to parse response: $e',
      );
    }
  }

  // ─────────────────── Public API ───────────────────

  /// HTTP **GET**
  Future<ApiResponse<T>> get<T>(
    String path, {
    T Function(dynamic json)? fromJsonModel,
    Map<String, String>? queryParams,
    bool auth = true,
  }) async {
    try {
      final response = await _client.get(
        _uri(path, queryParams: queryParams),
        headers: await _headers(auth: auth),
      ).timeout(const Duration(seconds: 15));
      return _parse<T>(response, fromJsonModel);
    } on SocketException {
      return ApiResponse<T>(message: 'No internet connection');
    } catch (e) {
      return ApiResponse<T>(message: e.toString());
    }
  }

  /// HTTP **POST**
  Future<ApiResponse<T>> post<T>(
    String path, {
    Map<String, dynamic>? body,
    T Function(dynamic json)? fromJsonModel,
    bool auth = true,
  }) async {
    try {
      final response = await _client.post(
        _uri(path),
        headers: await _headers(auth: auth),
        body: body != null ? jsonEncode(body) : null,
      ).timeout(const Duration(seconds: 15));
      return _parse<T>(response, fromJsonModel);
    } on SocketException {
      return ApiResponse<T>(message: 'No internet connection');
    } catch (e) {
      return ApiResponse<T>(message: e.toString());
    }
  }

  /// HTTP **PATCH**
  Future<ApiResponse<T>> patch<T>(
    String path, {
    Map<String, dynamic>? body,
    T Function(dynamic json)? fromJsonModel,
    bool auth = true,
  }) async {
    try {
      final response = await _client.patch(
        _uri(path),
        headers: await _headers(auth: auth),
        body: body != null ? jsonEncode(body) : null,
      ).timeout(const Duration(seconds: 15));
      return _parse<T>(response, fromJsonModel);
    } on SocketException {
      return ApiResponse<T>(message: 'No internet connection');
    } catch (e) {
      return ApiResponse<T>(message: e.toString());
    }
  }

  /// HTTP **DELETE**
  Future<ApiResponse<T>> delete<T>(
    String path, {
    T Function(dynamic json)? fromJsonModel,
    bool auth = true,
  }) async {
    try {
      final response = await _client.delete(
        _uri(path),
        headers: await _headers(auth: auth),
      ).timeout(const Duration(seconds: 15));
      return _parse<T>(response, fromJsonModel);
    } on SocketException {
      return ApiResponse<T>(message: 'No internet connection');
    } catch (e) {
      return ApiResponse<T>(message: e.toString());
    }
  }
}
