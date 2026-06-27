import 'dart:async';

import 'package:adnetwork/core/services/link_queue_manager.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// WebView instances loading URLs directly as top-level pages.
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

        // Keep the WebViews in the tree but offstage when there is no work
        return Offstage(
          offstage: activeCount == 0,
          child: RepaintBoundary(
            child: isPipMode
                ? Column(
                    children: [
                      for (int i = 0; i < LinkQueueManager.maxSlots; i++)
                        _SlotWrapper(
                          slotIndex: i,
                          isPipMode: true,
                          activeLink: slots.length > i ? slots[i] : null,
                        ),
                    ],
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (int i = 0; i < LinkQueueManager.maxSlots; i++)
                        _SlotWrapper(
                          slotIndex: i,
                          isPipMode: false,
                          activeLink: slots.length > i ? slots[i] : null,
                        ),
                    ],
                  ),
          ),
        );
      },
    );
  }
}

class _SlotWrapper extends StatelessWidget {
  final int slotIndex;
  final bool isPipMode;
  final ActiveLink? activeLink;

  const _SlotWrapper({
    required this.slotIndex,
    required this.isPipMode,
    required this.activeLink,
  });

  @override
  Widget build(BuildContext context) {
    final bool isActive = activeLink != null;

    if (isPipMode) {
      return Expanded(
        child: Offstage(
          offstage: !isActive,
          child: _SlotWebView(
            key: ValueKey('slot_$slotIndex'),
            slotIndex: slotIndex,
            activeLink: activeLink,
          ),
        ),
      );
    } else {
      return Offstage(
        offstage: !isActive,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 80,
          height: 142,
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
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
                    width: 360,
                    height: 640,
                    child: _SlotWebView(
                      key: ValueKey('slot_$slotIndex'),
                      slotIndex: slotIndex,
                      activeLink: activeLink,
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
                      'Slot ${slotIndex + 1}',
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
      );
    }
  }
}

class _SlotWebView extends StatefulWidget {
  final int slotIndex;
  final ActiveLink? activeLink;

  const _SlotWebView({
    super.key,
    required this.slotIndex,
    required this.activeLink,
  });

  @override
  State<_SlotWebView> createState() => _SlotWebViewState();
}

class _SlotWebViewState extends State<_SlotWebView> {
  late final WebViewController _controller;
  Timer? _viewTimer;
  Timer? _timeoutTimer;
  Timer? _masterTimeout; // Safety-net: guarantees slot is freed no matter what
  bool _isLoading = false;
  bool _finished = false;
  int _blankSecondsCount = 0;
  int _inWebViewReloadCount = 0;
  String? _loadedUrl;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            if (mounted) {
              setState(() {
                _isLoading = true;
              });
            }
            // Reset the countdown view timer on new page loads/redirects
            _viewTimer?.cancel();
            _blankSecondsCount = 0;
          },
          onPageFinished: (String url) {
            if (mounted) {
              setState(() {
                _isLoading = false;
              });
            }
            _onPageFinished(url);
          },
          onWebResourceError: (WebResourceError error) {
            if (mounted) {
              setState(() {
                _isLoading = false;
              });
            }
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

    _checkAndLoad();
  }

  @override
  void didUpdateWidget(covariant _SlotWebView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.activeLink?.url != oldWidget.activeLink?.url ||
        widget.activeLink?.retryCount != oldWidget.activeLink?.retryCount ||
        widget.activeLink?.displayedAt != oldWidget.activeLink?.displayedAt) {
      _checkAndLoad();
    }
  }

  void _checkAndLoad() {
    final link = widget.activeLink;
    if (link == null) {
      // Slot became idle, load about:blank to release resources and stop audio/video
      if (_loadedUrl != null && _loadedUrl != 'about:blank') {
        _loadedUrl = 'about:blank';
        _finished = true;
        _isLoading = false;
        _viewTimer?.cancel();
        _timeoutTimer?.cancel();
        _masterTimeout?.cancel();
        try {
          _controller.loadRequest(Uri.parse('about:blank'));
        } catch (_) {}
      }
      return;
    }

    _loadedUrl = link.url;
    _finished = false;
    _isLoading = true;
    _blankSecondsCount = 0;
    _inWebViewReloadCount = 0;

    _viewTimer?.cancel();
    _timeoutTimer?.cancel();
    _masterTimeout?.cancel();

    try {
      final uri = Uri.parse(link.url);
      _controller.loadRequest(uri);
    } catch (e) {
      debugPrint(
        '[LinkQueue] ❌ Slot ${widget.slotIndex} Invalid URL: ${link.url}',
      );
      _finished = true;
      _isLoading = false;
      // Mark as error immediately so it's removed from queue
      WidgetsBinding.instance.addPostFrameCallback((_) {
        LinkQueueManager.instance.onSlotError(widget.slotIndex);
      });
    }

    debugPrint('[LinkQueue] ▶ Slot ${widget.slotIndex} loading: ${link.url}');

    // ── HARD TIMEOUT: 30s max to load ──
    _timeoutTimer = Timer(const Duration(seconds: 30), () {
      if (!_finished && mounted) {
        debugPrint(
          '[LinkQueue] ⏰ Slot ${widget.slotIndex} load timed out (30s): ${link.url}',
        );
        _finished = true;
        _viewTimer?.cancel();
        _masterTimeout?.cancel();
        LinkQueueManager.instance.onSlotError(widget.slotIndex);
      }
    });
  }

  @override
  void dispose() {
    _viewTimer?.cancel();
    _timeoutTimer?.cancel();
    _masterTimeout?.cancel();
    super.dispose();
  }

  /// Page loaded — check if it's an actual page or an error page.
  void _onPageFinished(String url) async {
    if (_finished) return;
    if (url == 'about:blank') return;

    // Cancel the 30s load timeout and any active view timers from previous redirects
    _timeoutTimer?.cancel();
    _viewTimer?.cancel();

    // ── MASTER SAFETY-NET: 45s max from page-finished to slot completion ──
    // This guarantees the slot is freed even if content checks hang,
    // blank-page loops get stuck, or the view timer somehow fails.
    _masterTimeout?.cancel();
    _masterTimeout = Timer(const Duration(seconds: 45), () {
      if (!_finished && mounted) {
        debugPrint(
          '[LinkQueue] 🛡️ Slot ${widget.slotIndex} master timeout (45s) — force-finishing: ${widget.activeLink?.url}',
        );
        _finished = true;
        _viewTimer?.cancel();
        _timeoutTimer?.cancel();
        LinkQueueManager.instance.onSlotError(widget.slotIndex);
      }
    });

    _checkPageLoaded(url);
  }

  /// Check if the page has rendered actual contents (not a blank/white screen)
  void _checkPageLoaded(String url) async {
    if (_finished) return;
    if (widget.activeLink == null) return;

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
              '[LinkQueue] 🔄 Slot ${widget.slotIndex} has been blank for 6s. Re-hitting link (attempt $_inWebViewReloadCount/2): ${widget.activeLink?.url}',
            );

            // Reset the load timeout timer
            _timeoutTimer?.cancel();
            _timeoutTimer = Timer(const Duration(seconds: 30), () {
              if (!_finished && mounted) {
                debugPrint(
                  '[LinkQueue] ⏰ Slot ${widget.slotIndex} timed out (30s) after blank reload: ${widget.activeLink?.url}',
                );
                _finished = true;
                _viewTimer?.cancel();
                _masterTimeout?.cancel();
                LinkQueueManager.instance.onSlotError(widget.slotIndex);
              }
            });

            // Reload/re-hit the request in this webview
            try {
              final uri = Uri.parse(widget.activeLink!.url);
              _controller.loadRequest(uri);
            } catch (_) {}
            return;
          } else {
            // BUG FIX: Previously this just logged "letting it time out" but
            // there was NO timeout running (it was cancelled in onPageFinished).
            // Now we immediately call onSlotError to free the slot.
            debugPrint(
              '[LinkQueue] ⚠️ Slot ${widget.slotIndex} exhausted in-webview re-hits, force-erroring slot: ${widget.activeLink?.url}',
            );
            _finished = true;
            _viewTimer?.cancel();
            _masterTimeout?.cancel();
            LinkQueueManager.instance.onSlotError(widget.slotIndex);
            return;
          }
        }

        debugPrint(
          '[LinkQueue] ⏳ Slot ${widget.slotIndex} is still blank/white screen ($_blankSecondsCount/6s before re-hit), retrying check in 1s...',
        );
        _viewTimer = Timer(
          const Duration(seconds: 1),
          () {
            if (mounted) {
              _checkPageLoaded(url);
            }
          },
        );
        return;
      }
    } catch (_) {
      // JS execution failed (e.g. cross-origin iframe security issues on runJavaScriptReturningResult)
      // Treat as success so we don't get stuck in a loop.
    }

    // Page has actual content — start the random 5–10s view timer
    debugPrint('[LinkQueue] ✅ Slot ${widget.slotIndex} loaded content: $url (viewing for ${LinkQueueManager.instance.randomViewDuration.inSeconds}s)');
    final duration = LinkQueueManager.instance.randomViewDuration;
    _viewTimer = Timer(duration, () {
      if (!_finished && mounted) {
        debugPrint('[LinkQueue] ✅ Slot ${widget.slotIndex} view time elapsed — marking finished: $url');
        _finished = true;
        _masterTimeout?.cancel();
        LinkQueueManager.instance.onSlotFinished(widget.slotIndex);
      }
    });
  }

  /// Network-level error (DNS, connection refused, etc.)
  void _onWebResourceError(WebResourceError error) {
    if (_finished) return;
    if (error.isForMainFrame ?? false) {
      debugPrint(
        '[LinkQueue] ❌ Slot ${widget.slotIndex} main-frame error: ${error.description}',
      );
      _finished = true;
      _viewTimer?.cancel();
      _timeoutTimer?.cancel();
      _masterTimeout?.cancel();
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
