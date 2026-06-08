import 'dart:async';

import 'package:adnetwork/config/asset_manager.dart';
import 'package:adnetwork/config/theme/routes_config.dart';
import 'package:adnetwork/core/functions/navigator.dart';
import 'package:flutter/material.dart';
import 'package:pretty_animated_text/pretty_animated_text.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:adnetwork/core/models/app_update_model.dart';
import 'package:adnetwork/layers/data/repo/remote/app_update_repository.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  final GlobalKey<OffsetTextState> offsetTextBTKey =
      GlobalKey<OffsetTextState>();

  @override
  void initState() {
    super.initState();
    _checkAppUpdateAndNavigate();
  }

  bool _shouldUpdate(
    String currentVersion,
    String newVersion,
  ) {
    try {
      final currentParts = currentVersion
          .split('.')
          .map((e) => int.tryParse(e) ?? 0)
          .toList();
      final newParts = newVersion
          .split('.')
          .map((e) => int.tryParse(e) ?? 0)
          .toList();

      final maxLength = currentParts.length > newParts.length
          ? currentParts.length
          : newParts.length;
      for (int i = 0; i < maxLength; i++) {
        final c = i < currentParts.length ? currentParts[i] : 0;
        final n = i < newParts.length ? newParts[i] : 0;
        if (n > c) return true;
        if (c > n) return false;
      }
    } catch (_) {}

    return false;
  }

  Future<void> _checkAppUpdateAndNavigate() async {
    // Wait for the animation to complete
    await Future.delayed(const Duration(milliseconds: 2600));

    if (!mounted) return;

    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;

      final updateRepo = AppUpdateRepository();
      final response = await updateRepo.checkUpdate('adnetworkpro');

      if (response.success == true && response.data != null) {
        final updateData = response.data!;
        final newVersion = updateData.version ?? currentVersion;

        debugPrint('[AppUpdate] Current Version: "$currentVersion", Remote Version: "$newVersion"');
        debugPrint('[AppUpdate] Should update? ${_shouldUpdate(currentVersion, newVersion)}');

        if (_shouldUpdate(currentVersion, newVersion)) {
          if (!mounted) return;
          _showUpdateDialog(updateData);
          return; // Wait for user interaction
        }
      }
    } catch (e) {
      // Ignore errors and proceed
    }

    if (mounted) {
      navigateAndReplace(context, Routes.login);
    }
  }

  void _showUpdateDialog(AppUpdateModel updateData) {
    final isMandatory = updateData.isMandatory == 1;
    double progress = 0.0;
    bool isDownloading = false;
    bool isDownloaded = false;
    String savedFilePath = '';
    CancelToken? cancelToken;

    showDialog(
      context: context,
      barrierDismissible: !isMandatory,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return PopScope(
              canPop: !isMandatory && !isDownloading,
              child: AlertDialog(
                title: const Text('Update Available'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'A new version (${updateData.version}) is available. Please update to continue.',
                    ),
                    if (updateData.releaseNotes != null &&
                        updateData.releaseNotes!.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      const Text(
                        'Release Notes:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(updateData.releaseNotes!),
                    ],
                    if (isDownloading || isDownloaded)
                      const SizedBox(height: 20),
                    if (isDownloading) ...[
                      LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.grey.withValues(alpha: 0.2),
                        color: Theme.of(context).primaryColor,
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: Text(
                          'Downloading: ${(progress * 100).toStringAsFixed(1)}%',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                    if (isDownloaded)
                      const Center(
                        child: Text(
                          'Download complete! Ready to install.',
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                actions: [
                  if (!isMandatory && !isDownloading)
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        navigateAndReplace(context, Routes.login);
                      },
                      child: const Text('Later'),
                    ),
                  if (isDownloading)
                    TextButton(
                      onPressed: () {
                        cancelToken?.cancel();
                        setState(() {
                          isDownloading = false;
                          progress = 0.0;
                        });
                      },
                      child: const Text('Cancel'),
                    )
                  else
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDownloaded
                            ? Colors.green
                            : Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () async {
                        if (isDownloaded) {
                          // Install the APK
                          OpenFilex.open(savedFilePath);
                          return;
                        }

                        if (updateData.downloadUrl == null) return;

                        setState(() {
                          isDownloading = true;
                          progress = 0.0;
                        });

                        final cleanUrl = updateData.downloadUrl!.replaceAll(
                          RegExp(r'\s+'),
                          '',
                        );
                        cancelToken = CancelToken();

                        try {
                          final dir = await getApplicationSupportDirectory();
                          savedFilePath =
                              '${dir.path}/update_${updateData.version}.apk';

                          await Dio().download(
                            cleanUrl,
                            savedFilePath,
                            cancelToken: cancelToken,
                            onReceiveProgress: (received, total) {
                              if (total != -1) {
                                setState(() {
                                  progress = received / total;
                                });
                              }
                            },
                          );

                          setState(() {
                            isDownloading = false;
                            isDownloaded = true;
                          });

                          // Automatically attempt to install after download
                          OpenFilex.open(savedFilePath);
                        } catch (e) {
                          if (e is DioException && CancelToken.isCancel(e)) {
                            // User cancelled
                          } else {
                            setState(() {
                              isDownloading = false;
                              progress = 0.0;
                            });
                            debugPrint('Download failed: $e');
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Download failed. Please check your connection and try again.',
                                  ),
                                ),
                              );
                            }
                          }
                        }
                      },
                      child: Text(
                        isDownloaded ? 'Install Update' : 'Update Now',
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode
        ? const Color(0xFF121212)
        : const Color(0xFFF8F9FA);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Beautiful Animated Card Effect for the Logo
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0.4, end: 1.0),
                duration: const Duration(milliseconds: 1400),
                curve: Curves.elasticOut, // Gives a nice pop-out bounce
                builder: (context, scale, child) {
                  return Transform.scale(scale: scale, child: child);
                },
                child: Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 0, 0, 0),
                    borderRadius: BorderRadius.circular(36),
                    boxShadow: [
                      BoxShadow(
                        color: isDarkMode
                            ? Colors.black.withValues(alpha: 0.6)
                            : Colors.black.withValues(alpha: 0.08),
                        blurRadius: 30,
                        offset: const Offset(0, 15),
                      ),
                      BoxShadow(
                        color: isDarkMode
                            ? Colors.black.withValues(alpha: 0.4)
                            : Colors.black.withValues(alpha: 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Image.asset(
                    ImageAssets.adNetworkLogo,
                    width: 140,
                    height: 140,
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Animated Text using pretty_animated_text
              OffsetText(
                key: offsetTextBTKey,
                text: "AD NETWORK",
                duration: const Duration(milliseconds: 300),
                type: AnimationType.letter,
                slideType: SlideAnimationType.bottomTop,
                textStyle: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2.0,
                  color: isDarkMode ? Colors.white : const Color(0xFF2D3142),
                  shadows: [
                    Shadow(
                      color: isDarkMode
                          ? Colors.black.withValues(alpha: 0.5)
                          : Colors.black.withValues(alpha: 0.1),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
