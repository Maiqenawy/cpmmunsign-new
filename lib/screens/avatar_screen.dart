import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'avatar_sign_model.dart';

class AvatarScreen extends StatefulWidget {
  final List<AvatarSign> signs;

  /// When true the avatar shows a "thinking" pose while the API responds.
  final bool isLoading;

  const AvatarScreen({
    super.key,
    required this.signs,
    this.isLoading = false,
  });

  @override
  State<AvatarScreen> createState() => _AvatarScreenState();
}

class _AvatarScreenState extends State<AvatarScreen> {
  InAppWebViewController? controller;
  int  currentSign   = 0;
  int  currentFrame  = 0;
  bool isJsReady      = false;
  bool isAnimating    = false;
  bool _pendingAnim   = false;

  // ── In-process GLB HTTP server (shared across all widget instances) ──────────
  //
  // Why: Android WebView's Fetch API cannot load file:// URLs on Chromium-based
  // WebViews (including Huawei), even with allowUniversalAccessFromFileURLs.
  // Serving the GLB over http://127.0.0.1 is universally supported by Fetch.
  static HttpServer? _httpServer;
  static int         _httpPort = 0;

  static Future<void> _ensureGlbServer() async {
    if (_httpServer != null) return; // already running

    // Load the GLB asset once, keep it in memory for the server lifetime
    final data  = await rootBundle.load('assets/avatar.glb');
    final bytes = data.buffer.asUint8List();

    _httpServer = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    _httpPort   = _httpServer!.port;
    debugPrint('▶ GLB server http://127.0.0.1:$_httpPort/avatar.glb');

    _httpServer!.listen((req) async {
      // Blanket CORS so Fetch from any origin (file://, appassets://, etc.) works
      req.response.headers
        ..set('Access-Control-Allow-Origin',  '*')
        ..set('Access-Control-Allow-Methods', 'GET, OPTIONS')
        ..set('Access-Control-Allow-Headers', '*');

      if (req.method == 'OPTIONS') {
        req.response.statusCode = HttpStatus.ok;
      } else if (req.uri.path == '/avatar.glb') {
        req.response
          ..statusCode = HttpStatus.ok
          ..headers.set('Content-Type',   'model/gltf-binary')
          ..headers.set('Content-Length', bytes.length.toString())
          ..add(bytes);
      } else {
        req.response.statusCode = HttpStatus.notFound;
      }

      await req.response.close();
    });
  }

  // ── JS helper ──────────────────────────────────────────────────────────────
  void _js(String code) => controller?.evaluateJavascript(source: code);

  // ── Widget update ───────────────────────────────────────────────────────────
  @override
  void didUpdateWidget(covariant AvatarScreen old) {
    super.didUpdateWidget(old);
    if (!isJsReady) return;

    // Loading flag changed
    if (widget.isLoading != old.isLoading) {
      if (widget.isLoading) {
        _js("if(window.setThinkingMode) window.setThinkingMode();");
        return;
      } else if (widget.signs.isEmpty && !isAnimating) {
        _js("if(window.setIdleMode) window.setIdleMode();");
        return;
      }
    }

    // Signs cleared
    if (widget.signs.isEmpty) {
      if (!isAnimating) _js("if(window.setIdleMode) window.setIdleMode();");
      return;
    }

    // New sign set received
    if (old.signs != widget.signs && widget.signs.isNotEmpty) {
      currentSign  = 0;
      currentFrame = 0;
      startAnimation();
    }
  }

  // ── Sign animation playback ─────────────────────────────────────────────────
  Future<void> startAnimation() async {
    if (isAnimating || widget.signs.isEmpty || !isJsReady) return;
    isAnimating = true;

    try {
      while (mounted && currentSign < widget.signs.length) {
        final sign = widget.signs[currentSign];
        currentFrame = 0;

        while (mounted && currentFrame < sign.landmarks.length) {
          final flat = List<double>.from(sign.landmarks[currentFrame]);

          if (flat.length >= 258) {
            final left  = _chunkBy3(flat.sublist(132, 195));
            final right = _chunkBy3(flat.sublist(195, 258));
            final data  = jsonEncode({'leftHand': left, 'rightHand': right});

            await controller?.evaluateJavascript(
              source:
                'if(typeof window.animateFrame==="function")'
                'window.animateFrame($data);',
            );
          }

          await Future.delayed(const Duration(milliseconds: 50)); // 20 fps
          currentFrame++;
        }
        currentSign++;
      }

      if (mounted) _js("if(window.setIdleMode) window.setIdleMode();");
    } catch (e) {
      debugPrint('Animation loop error: $e');
    } finally {
      isAnimating  = false;
      currentSign  = 0;
      currentFrame = 0;
    }
  }

  /// Reshape [x,y,z,x,y,z,...] → [[x,y,z],[x,y,z],...].
  List<List<double>> _chunkBy3(List<double> flat) {
    final out = <List<double>>[];
    for (int i = 0; i < flat.length; i += 3) {
      out.add([flat[i], flat[i + 1], flat[i + 2]]);
    }
    return out;
  }

  // ── Build ───────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return Container(
        color: const Color(0xFF0D1B2A),
        alignment: Alignment.center,
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.smart_toy_outlined, size: 64, color: Colors.teal),
            SizedBox(height: 10),
            Text(
              'Avatar animation is optimised for mobile platforms.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ],
        ),
      );
    }

    return InAppWebView(
      initialFile: 'assets/avatar_player.html',

      initialSettings: InAppWebViewSettings(
        javaScriptEnabled: true,
        allowFileAccessFromFileURLs: true,
        allowUniversalAccessFromFileURLs: true,
        mediaPlaybackRequiresUserGesture: false,
      ),

      // Called once when WebView is created — register the JS↔Flutter channel
      onWebViewCreated: (ctrl) {
        controller = ctrl;

        ctrl.addJavaScriptHandler(
          handlerName: 'FlutterBridge',
          callback: (args) {
            if (args.isEmpty) return;
            if (args[0] == 'MODEL_LOADED') {
              isJsReady = true;
              debugPrint(
                'JS READY — pending=$_pendingAnim '
                'signs=${widget.signs.length} loading=${widget.isLoading}',
              );
              if (_pendingAnim && widget.signs.isNotEmpty) {
                _pendingAnim = false;
                startAnimation();
              } else if (widget.isLoading) {
                _js("if(window.setThinkingMode) window.setThinkingMode();");
              }
            }
          },
        );
      },

      // Called when the HTML + scripts finish loading.
      // Start (or reuse) the GLB HTTP server, then hand the URL to the page.
      onLoadStop: (ctrl, url) async {
        await _ensureGlbServer();
        await ctrl.evaluateJavascript(
          source:
            'if(typeof window.startLoadAvatar==="function")'
            'window.startLoadAvatar("http://127.0.0.1:$_httpPort/avatar.glb");',
        );
      },

      onConsoleMessage: (ctrl, msg) => debugPrint('JS: ${msg.message}'),
    );
  }
}
