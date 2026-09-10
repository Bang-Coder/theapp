import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:webview_flutter/webview_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GreenScape',
      theme: ThemeData(primarySwatch: Colors.green),
      home: const HtmlViewerScreen(),
    );
  }
}

class HtmlViewerScreen extends StatefulWidget {
  const HtmlViewerScreen({super.key});
  @override
  State<HtmlViewerScreen> createState() => _HtmlViewerScreenState();
}

class _HtmlViewerScreenState extends State<HtmlViewerScreen> {
  late final WebViewController _controller;
  bool _ready = false;
  String _status = "Loading...";

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFF0b0f11))
      ..setNavigationDelegate(NavigationDelegate(
        onPageStarted: (url) {
          debugPrint("🌐 Started: $url");
          if (mounted) setState(() => _status = "Page started");
        },
        onPageFinished: (url) {
          debugPrint("✅ Finished: $url");
          if (mounted) setState(() => _status = "Page finished");
        },
        onWebResourceError: (err) {
          debugPrint("❌ Resource error: ${err.description} (${err.errorCode})");
          if (mounted) setState(() => _status = "Error: ${err.description}");
        },
        onConsoleMessage: (msg) {
          debugPrint("🖥 Console: ${msg.message}");
        },
      ));

    _loadHtml();
  }

  Future<void> _loadHtml() async {
    try {
      final html = await rootBundle.loadString('assets/html/index.html');
      debugPrint("📄 HTML size: ${html.length} chars");

      // ⚡ THE KEY FIX — pass a baseUrl so the WebView
      // treats the page as coming from a real https origin.
      // Without this, Android blocks all external requests
      // (Tailwind, React, Babel, Google Fonts, Unsplash).
      await _controller.loadHtmlString(
        html,
        baseUrl: 'https://greenscape.app/', // any real-looking domain
      );

      if (mounted) setState(() => _ready = true);
    } catch (e, st) {
      debugPrint("💥 $e\n$st");
      if (mounted) setState(() => _status = "Failed: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0b0f11),
      body: SafeArea(
        child: Stack(
          children: [
            WebViewWidget(controller: _controller),
            if (!_ready)
              Container(
                color: const Color(0xFF0b0f11),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(color: Color(0xFF00e676)),
                      const SizedBox(height: 16),
                      Text(_status,
                          style: const TextStyle(color: Colors.white70)),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
