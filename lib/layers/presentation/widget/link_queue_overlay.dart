import 'dart:async';
import 'dart:math';

import 'package:adnetwork/core/services/link_queue_manager.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// 2 WebView instances stacked vertically (35px each), loading URLs
/// directly as top-level pages — no iframes, no X-Frame-Options issues.
class LinkQueueOverlay extends StatelessWidget {
  final bool isPipMode;

  const LinkQueueOverlay({super.key, this.isPipMode = false});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ActiveLink?>>(
      stream: LinkQueueManager.instance.slotsStream,
      initialData: LinkQueueManager.instance.slots,
      builder: (context, snapshot) {
        final slots = snapshot.data ?? [];
        final activeCount = slots.where((s) => s != null).length;
        if (activeCount == 0) return const SizedBox.shrink();

        return RepaintBoundary(
          child: isPipMode
              ? Column(
                  children: [
                    for (int i = 0; i < LinkQueueManager.maxSlots; i++)
                      if (slots.length > i && slots[i] != null)
                        Expanded(
                          key: ValueKey(
                            'slot_${i}_${slots[i]!.url}_${slots[i]!.retryCount}_${slots[i]!.displayedAt.millisecondsSinceEpoch}',
                          ),
                          child: _SlotWebView(slotIndex: i, url: slots[i]!.url),
                        ),
                  ],
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (int i = 0; i < LinkQueueManager.maxSlots; i++)
                      if (slots.length > i && slots[i] != null)
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: 80,
                          height: 142,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Theme.of(
                                context,
                              ).colorScheme.primary.withValues(alpha: 0.5),
                              width: 1.5,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.25),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10.5),
                            child: Stack(
                              children: [
                                FittedBox(
                                  fit: BoxFit.contain,
                                  child: SizedBox(
                                    key: ValueKey(
                                      'slot_${i}_${slots[i]!.url}_${slots[i]!.retryCount}_${slots[i]!.displayedAt.millisecondsSinceEpoch}',
                                    ),
                                    width: 360,
                                    height: 640,
                                    child: _SlotWebView(
                                      slotIndex: i,
                                      url: slots[i]!.url,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 4,
                                  left: 4,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 5,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(
                                        alpha: 0.65,
                                      ),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      'Slot ${i + 1}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 8,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                  ],
                ),
        );
      },
    );
  }
}

/// A single 35px-tall WebView that loads a URL directly (top-level page).
class _SlotWebView extends StatefulWidget {
  final int slotIndex;
  final String url;

  const _SlotWebView({super.key, required this.slotIndex, required this.url});

  @override
  State<_SlotWebView> createState() => _SlotWebViewState();
}

class _SlotWebViewState extends State<_SlotWebView> {
  late final WebViewController _controller;
  Timer? _viewTimer;
  Timer? _timeoutTimer;
  bool _isLoading = true;
  bool _finished = false;
  int _blankSecondsCount = 0;
  int _inWebViewReloadCount = 0;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
            // Reset the countdown view timer on new page loads/redirects
            _viewTimer?.cancel();
            _blankSecondsCount = 0;
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
            _onPageFinished(url);
          },
          onWebResourceError: (WebResourceError error) {
            setState(() {
              _isLoading = false;
            });
            _onWebResourceError(error);
          },
          onHttpError: (HttpResponseError error) {
            // Ignore subresource HTTP errors (like 404/500 tracking scripts) to avoid closing prematurely.
            debugPrint(
              '[LinkQueue] Slot ${widget.slotIndex} Subresource HTTP Error: ${error.response?.statusCode} on ${error.request?.uri}',
            );
          },
        ),
      );

    try {
      final uri = Uri.parse(widget.url);
      _controller.loadRequest(uri);
    } catch (e) {
      debugPrint(
        '[LinkQueue] ❌ Slot ${widget.slotIndex} Invalid URL: ${widget.url}',
      );
      _finished = true;
      // Mark as error immediately so it's removed from queue
      WidgetsBinding.instance.addPostFrameCallback((_) {
        LinkQueueManager.instance.onSlotError(widget.slotIndex);
      });
    }

    debugPrint('[LinkQueue] ▶ Slot ${widget.slotIndex} loading: ${widget.url}');

    // ── HARD TIMEOUT: 30s max to load. If page doesn't load by then → error ──
    _timeoutTimer = Timer(const Duration(seconds: 30), () {
      if (!_finished) {
        debugPrint(
          '[LinkQueue] ⏰ Slot ${widget.slotIndex} timed out (30s): ${widget.url}',
        );
        _finished = true;
        _viewTimer?.cancel();
        LinkQueueManager.instance.onSlotError(widget.slotIndex);
      }
    });
  }

  @override
  void dispose() {
    _viewTimer?.cancel();
    _timeoutTimer?.cancel();
    super.dispose();
  }

  /// Page loaded — check if it's an actual page or an error page.
  void _onPageFinished(String url) async {
    if (_finished) return;

    // Cancel the 30s timeout and any active view timers from previous redirects
    _timeoutTimer?.cancel();
    _viewTimer?.cancel();

    _checkPageLoaded(url);
  }

  /// Check if the page has rendered actual contents (not a blank/white screen)
  void _checkPageLoaded(String url) async {
    if (_finished) return;

    try {
      final result = await _controller.runJavaScriptReturningResult('''
        (function() {
          var title = (document.title || '').toLowerCase();
          var body = (document.body ? document.body.innerText || '' : '').substring(0, 500).toLowerCase();
          var combined = title + ' ' + body;
          if (
            combined.indexOf('not found') !== -1 ||
            combined.indexOf('404') !== -1 ||
            combined.indexOf('err_') !== -1 ||
            combined.indexOf('cannot be reached') !== -1 ||
            combined.indexOf('connection refused') !== -1 ||
            combined.indexOf('dns_probe') !== -1 ||
            combined.indexOf('web page not available') !== -1 ||
            combined.indexOf('this site can') !== -1 ||
            combined.indexOf('page not found') !== -1
          ) {
            return 'error';
          }

          var text = (document.body ? document.body.innerText || '' : '').trim();
          var hasImages = document.getElementsByTagName('img').length > 0;
          var hasIframes = document.getElementsByTagName('iframe').length > 0;
          var hasLinks = document.getElementsByTagName('a').length > 0;

          if (text.length === 0 && !hasImages && !hasIframes && !hasLinks) {
            return 'blank';
          }
          return 'ok';
        })();
      ''');

      final status = result.toString().replaceAll('"', '');

      if (status == 'error') {
        debugPrint(
          '[LinkQueue] ❌ Slot ${widget.slotIndex} error page detected: $url',
        );
        _finished = true;
        _viewTimer?.cancel();
        LinkQueueManager.instance.onSlotError(widget.slotIndex);
        return;
      }

      if (status == 'blank') {
        _blankSecondsCount++;
        if (_blankSecondsCount >= 6) {
          if (_inWebViewReloadCount < 2) {
            _inWebViewReloadCount++;
            _blankSecondsCount = 0;
            debugPrint(
              '[LinkQueue] 🔄 Slot ${widget.slotIndex} has been blank for 6s. Re-hitting link (attempt $_inWebViewReloadCount/2): ${widget.url}',
            );

            // Reset the load timeout timer
            _timeoutTimer?.cancel();
            _timeoutTimer = Timer(const Duration(seconds: 30), () {
              if (!_finished) {
                debugPrint(
                  '[LinkQueue] ⏰ Slot ${widget.slotIndex} timed out (30s): ${widget.url}',
                );
                _finished = true;
                _viewTimer?.cancel();
                LinkQueueManager.instance.onSlotError(widget.slotIndex);
              }
            });

            // Reload/re-hit the request in this webview
            try {
              final uri = Uri.parse(widget.url);
              _controller.loadRequest(uri);
            } catch (_) {}
            return;
          } else {
            debugPrint(
              '[LinkQueue] ⚠️ Slot ${widget.slotIndex} exhausted in-webview re-hits, letting it time out...',
            );
          }
        }

        debugPrint(
          '[LinkQueue] ⏳ Slot ${widget.slotIndex} is still blank/white screen ($_blankSecondsCount/6s before re-hit), retrying check in 1s...',
        );
        _viewTimer = Timer(
          const Duration(seconds: 1),
          () => _checkPageLoaded(url),
        );
        return;
      }
    } catch (_) {
      // JS execution failed (e.g. cross-origin iframe security issues on runJavaScriptReturningResult)
      // Treat as success so we don't get stuck in a loop.
    }

    // Page has actual content — start the random 5–10s view timer
    debugPrint('[LinkQueue] ✅ Slot ${widget.slotIndex} loaded content: $url');
    final duration = LinkQueueManager.instance.randomViewDuration;
    _viewTimer = Timer(duration, () {
      if (!_finished) {
        _finished = true;
        LinkQueueManager.instance.onSlotFinished(widget.slotIndex);
      }
    });
  }

  /// Network-level error (DNS, connection refused, etc.)
  void _onWebResourceError(WebResourceError error) {
    if (_finished) return;
    if (error.isForMainFrame ?? false) {
      debugPrint(
        '[LinkQueue] ❌ Slot ${widget.slotIndex} error: ${error.description}',
      );
      _finished = true;
      _viewTimer?.cancel();
      _timeoutTimer?.cancel();
      LinkQueueManager.instance.onSlotError(widget.slotIndex);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            Positioned(
              right: 8,
              bottom: 8,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.65),
                  shape: BoxShape.circle,
                ),
                child: const SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(
                    strokeWidth: 1.5,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
