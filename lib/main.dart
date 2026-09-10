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
      ..setOnConsoleMessage((msg) {
        debugPrint("Console: ${msg.message}");
      })
      ..setNavigationDelegate(NavigationDelegate(
        onPageStarted: (url) {
          debugPrint("Page started: $url");
          if (mounted) setState(() => _status = "Page started");
        },
        onPageFinished: (url) {
          debugPrint("Page finished: $url");
          if (mounted) setState(() => _status = "Page finished");
        },
        onWebResourceError: (err) {
          debugPrint("Resource error: ${err.description} (${err.errorCode})");
          if (mounted) setState(() => _status = "Error: ${err.description}");
        },
      ));

    _loadHtml();
  }

  Future<void> _loadHtml() async {
    try {
      final html = await rootBundle.loadString('assets/html/index.html');
      debugPrint("HTML size: ${html.length} chars");

      await _controller.loadHtmlString(
        html,
        baseUrl: 'https://greenscape.app/',
      );

      if (mounted) setState(() => _ready = true);
    } catch (e, st) {
      debugPrint("Failed: $e\n$st");
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
                      Text(_status, style: const TextStyle(color: Colors.white70)),
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
