import 'dart:io';
import 'package:flutter/services.dart';

class VpnDnsChecker {
  static const MethodChannel _channel = MethodChannel('com.example.adnetwork/vpn_dns');

  /// Checks if VPN is connected (works on Android and iOS).
  static Future<bool> isVpnActive() async {
    // 1. Check native Android API if on Android
    if (Platform.isAndroid) {
      try {
        final Map<dynamic, dynamic>? result =
            await _channel.invokeMethod<Map<dynamic, dynamic>>('checkVpnDns');
        if (result != null && result['isVpnActive'] == true) {
          return true;
        }
      } catch (_) {
        // Fallback to network interfaces check on failure
      }
    }

    // 2. Fallback / iOS check: inspect network interfaces
    try {
      final interfaces = await NetworkInterface.list();
      return interfaces.any((interface) {
        final name = interface.name.toLowerCase();
        return name.contains('tun') ||
            name.contains('ppp') ||
            name.contains('tap') ||
            name.contains('p2p') ||
            name.contains('utun') ||
            name.contains('ipsec') ||
            name.contains('vpn');
      });
    } catch (_) {
      return false;
    }
  }

  /// Checks if Private DNS is active (Android-only setting).
  static Future<bool> isPrivateDnsActive() async {
    if (!Platform.isAndroid) return false;
    try {
      final Map<dynamic, dynamic>? result =
          await _channel.invokeMethod<Map<dynamic, dynamic>>('checkVpnDns');
      return result != null && result['isPrivateDnsActive'] == true;
    } catch (_) {
      return false;
    }
  }
}
