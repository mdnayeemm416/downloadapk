import 'dart:async';

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
                          child: _SlotWebView(
                            slotIndex: i,
                            url: slots[i]!.url,
                          ),
                        ),
                  ],
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (int i = 0; i < LinkQueueManager.maxSlots; i++)
                      if (slots.length > i && slots[i] != null)
                        SizedBox(
                          key: ValueKey(
                            'slot_${i}_${slots[i]!.url}_${slots[i]!.retryCount}_${slots[i]!.displayedAt.millisecondsSinceEpoch}',
                          ),
                          height: 35,
                          child: _SlotWebView(
                            slotIndex: i,
                            url: slots[i]!.url,
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
  bool _finished = false;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: _onPageFinished,
          onWebResourceError: _onWebResourceError,
          onHttpError: _onHttpError,
        ),
      );

    try {
      final uri = Uri.parse(widget.url);
      _controller.loadRequest(uri);
    } catch (e) {
      debugPrint('[LinkQueue] ❌ Slot ${widget.slotIndex} Invalid URL: ${widget.url}');
      _finished = true;
      // Mark as error immediately so it's removed from queue
      WidgetsBinding.instance.addPostFrameCallback((_) {
        LinkQueueManager.instance.onSlotError(widget.slotIndex);
      });
    }

    debugPrint('[LinkQueue] ▶ Slot ${widget.slotIndex} loading: ${widget.url}');

    // ── HARD TIMEOUT: 15s max to load. If page doesn't load by then → error ──
    _timeoutTimer = Timer(const Duration(seconds: 15), () {
      if (!_finished) {
        debugPrint(
          '[LinkQueue] ⏰ Slot ${widget.slotIndex} timed out (15s): ${widget.url}',
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

    // Cancel the 15s timeout — page loaded in time
    _timeoutTimer?.cancel();

    // Check the page title + body text for error indicators
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
          return 'ok';
        })();
      ''');

      final status = result.toString().replaceAll('"', '');

      if (status == 'error') {
        debugPrint(
          '[LinkQueue] ❌ Slot ${widget.slotIndex} error page detected: $url',
        );
        if (!_finished) {
          _finished = true;
          _viewTimer?.cancel();
          LinkQueueManager.instance.onSlotError(widget.slotIndex);
        }
        return;
      }
    } catch (_) {
      // JS execution failed — treat as success (page loaded but cross-origin)
    }

    // Page is valid — start the random 5–10s view timer
    debugPrint('[LinkQueue] ✅ Slot ${widget.slotIndex} loaded: $url');
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

  /// HTTP error (404, 500, etc.)
  void _onHttpError(HttpResponseError error) {
    if (_finished) return;
    final statusCode = error.response?.statusCode ?? 0;
    if (statusCode >= 400) {
      debugPrint('[LinkQueue] ❌ Slot ${widget.slotIndex} HTTP $statusCode');
      _finished = true;
      _viewTimer?.cancel();
      _timeoutTimer?.cancel();
      LinkQueueManager.instance.onSlotError(widget.slotIndex);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRect(child: WebViewWidget(controller: _controller));
  }
}
