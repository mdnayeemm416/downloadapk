import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:adnetwork/core/services/api_client.dart';

class MobileConfig {
  final String adsHeight;
  final String adsWidth;
  final String allowDns;
  final String campaignSeconds;
  final String maxAdsTime;
  final String minAdsTime;
  final String useDeviceResolution;

  const MobileConfig({
    required this.adsHeight,
    required this.adsWidth,
    required this.allowDns,
    required this.campaignSeconds,
    required this.maxAdsTime,
    required this.minAdsTime,
    required this.useDeviceResolution,
  });

  static const defaultConfig = MobileConfig(
    adsHeight: "256",
    adsWidth: "256",
    allowDns: "0",
    campaignSeconds: "20",
    maxAdsTime: "15",
    minAdsTime: "10",
    useDeviceResolution: "1",
  );

  factory MobileConfig.fromJson(Map<String, dynamic> json) {
    // If the json has a "data" field, look inside it; otherwise parse the root object.
    final Map<String, dynamic> data = (json['data'] is Map<String, dynamic>)
        ? json['data']
        : json;

    return MobileConfig(
      adsHeight: data['ads_height']?.toString() ?? "256",
      adsWidth: data['ads_width']?.toString() ?? "256",
      allowDns: data['allow_dns']?.toString() ?? "0",
      campaignSeconds: data['campaign_seconds']?.toString() ?? "20",
      maxAdsTime: data['max_ads_time']?.toString() ?? "15",
      minAdsTime: data['min_ads_time']?.toString() ?? "10",
      useDeviceResolution: data['use_device_resolution']?.toString() ?? "1",
    );
  }

  Map<String, String> toJson() {
    return {
      'ads_height': adsHeight,
      'ads_width': adsWidth,
      'allow_dns': allowDns,
      'campaign_seconds': campaignSeconds,
      'max_ads_time': maxAdsTime,
      'min_ads_time': minAdsTime,
      'use_device_resolution': useDeviceResolution,
    };
  }
}

class MobileConfigManager {
  MobileConfigManager._();
  static final MobileConfigManager instance = MobileConfigManager._();

  static const String _storageKey = 'mobile_config';

  MobileConfig _config = MobileConfig.defaultConfig;

  MobileConfig get config => _config;

  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString(_storageKey);
      if (cached != null) {
        final json = jsonDecode(cached) as Map<String, dynamic>;
        _config = MobileConfig.fromJson(json);
      }
    } catch (e) {
      debugPrint('MobileConfigManager init error: $e');
    }
  }

  Future<void> fetchAndCacheConfig() async {
    try {
      final response = await ApiClient.instance.get('/api/mobile-config');
      if (response.isSuccess && response.data != null) {
        final rawData = response.data;
        if (rawData is Map<String, dynamic>) {
          _config = MobileConfig.fromJson(rawData);
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(_storageKey, jsonEncode(_config.toJson()));
          debugPrint('MobileConfigManager successfully updated and cached config: ${_config.toJson()}');
        } else {
          debugPrint('MobileConfigManager API data is not a Map: $rawData');
        }
      } else {
        debugPrint('MobileConfigManager API response unsuccessful: ${response.message}');
      }
    } catch (e) {
      debugPrint('MobileConfigManager fetchAndCacheConfig error: $e');
    }
  }
}
