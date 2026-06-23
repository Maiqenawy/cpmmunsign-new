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
  bool isJsReady   = false;
  bool isAnimating = false;

  // Completer signalled when JS sends 'ANIMATION_DONE'
  Completer<void>? _animDone;

  // ── In-process GLB HTTP server (shared across all instances) ─────────────────
  static HttpServer? _httpServer;
  static int         _httpPort = 0;

  static Future<void> _ensureGlbServer() async {
    if (_httpServer != null) return;
    final data  = await rootBundle.load('assets/avatar.glb');
    final bytes = data.buffer.asUint8List();
    _httpServer = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    _httpPort   = _httpServer!.port;
    debugPrint('▶ GLB server http://127.0.0.1:$_httpPort/avatar.glb');
    _httpServer!.listen((req) async {
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

  // ── JS helper ─────────────────────────────────────────────────────────────────
  void _js(String code) => controller?.evaluateJavascript(source: code);

  // ── Widget update ─────────────────────────────────────────────────────────────
  @override
  void didUpdateWidget(covariant AvatarScreen old) {
    super.didUpdateWidget(old);
    if (!isJsReady) return;

    if (widget.isLoading != old.isLoading) {
      if (widget.isLoading) {
        _js("if(window.setThinkingMode) window.setThinkingMode();");
        return;
      } else if (widget.signs.isEmpty && !isAnimating) {
        _js("if(window.setIdleMode) window.setIdleMode();");
        return;
      }
    }

    if (widget.signs.isEmpty) {
      if (!isAnimating) _js("if(window.setIdleMode) window.setIdleMode();");
      return;
    }

    if (old.signs != widget.signs && widget.signs.isNotEmpty) {
      startAnimation();
    }
  }

  // ── Animation — ONE bridge call for all frames (smooth!) ─────────────────────
  //
  // Previously: 60 frames × 1 evaluateJavascript call = 60 round-trips
  //             → actual frame time = bridge latency + 50ms = jerky
  //
  // Now: 1 evaluateJavascript call sends all frames,
  //      JS steps through them with setInterval at 20fps,
  //      RAF lerps at 60fps between keyframes → smooth.
  //
  Future<void> startAnimation() async {
    if (isAnimating || widget.signs.isEmpty || !isJsReady) return;
    isAnimating = true;
    _animDone   = Completer<void>();

    try {
      // ── Build all frames from all signs ─────────────────────────────────────
      final allFrames = <Map<String, dynamic>>[];

      for (final sign in widget.signs) {
        for (final rawFrame in sign.landmarks) {
          final flat = List<double>.from(rawFrame);
          
          if (flat.length >= 258) {
            allFrames.add({
              // pose: 33 landmarks × 4-stride (x,y,z, skip visibility)
              'p': _extractPose(flat.sublist(0, 132)),
              // hands: 21 landmarks × 3-stride (x,y,z)
              'l': _chunkBy3(flat.sublist(132, 195)),
              'r': _chunkBy3(flat.sublist(195, 258)),
            });
          }
        }
      }

      if (allFrames.isEmpty) return;

      // One serialisation, one bridge call
      final json = jsonEncode({'frames': allFrames, 'fps': 20});

      await controller?.evaluateJavascript(
        source:
          'if(typeof window.playAnimation==="function")'
          'window.playAnimation($json);',
      );

      // Wait for JS to signal ANIMATION_DONE (generous timeout)
      final timeoutMs = allFrames.length * 55 + 3000;
      await _animDone!.future
          .timeout(Duration(milliseconds: timeoutMs), onTimeout: () {});

    } catch (e) {
      debugPrint('Animation error: $e');
    } finally {
      isAnimating = false;
      _animDone   = null;
      if (mounted) _js("if(window.setIdleMode) window.setIdleMode();");
    }
  }

  // ── Landmark helpers ──────────────────────────────────────────────────────────

  // Round to 4 dp → reduces JSON size by ~3× with no visible quality loss
  static double _r(double v) => (v * 10000).round() / 10000.0;

  /// Pose: stride-4 (x,y,z, skip visibility) → 33 landmarks
  List<List<double>> _extractPose(List<double> flat) {
    final out = <List<double>>[];
    for (int i = 0; i + 3 <= flat.length; i += 4) {
      out.add([_r(flat[i]), _r(flat[i + 1]), _r(flat[i + 2])]);
    }
    return out;
  }

  /// Hand: stride-3 (x,y,z) → 21 landmarks
  List<List<double>> _chunkBy3(List<double> data) {
    final out = <List<double>>[];
    for (int i = 0; i < data.length; i += 3) {
      out.add([_r(data[i]), _r(data[i + 1]), _r(data[i + 2])]);
    }
    return out;
  }

  // ── Build ─────────────────────────────────────────────────────────────────────
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

      onWebViewCreated: (ctrl) {
        controller = ctrl;
        ctrl.addJavaScriptHandler(
          handlerName: 'FlutterBridge',
          callback: (args) {
            if (args.isEmpty) return;
            switch (args[0] as String) {
              case 'MODEL_LOADED':
                isJsReady = true;
                debugPrint('JS READY — signs=${widget.signs.length} loading=${widget.isLoading}');
                if (widget.isLoading) {
                  _js("if(window.setThinkingMode) window.setThinkingMode();");
                } else if (widget.signs.isNotEmpty) {
                  startAnimation();
                }
                break;
              case 'ANIMATION_DONE':
                // JS finished stepping through all frames
                _animDone?.complete();
                break;
            }
          },
        );
      },

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
