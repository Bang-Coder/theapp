import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle; // To load assets
import 'package:webview_flutter/webview_flutter.dart'; // To display HTML

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HTML Viewer',
      theme: ThemeData(primarySwatch: Colors.blue),
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

  @override
  void initState() {
    super.initState();

    // 1. Initialize the WebView controller
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted) // Enable JS if needed
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Optional: track loading progress
          },
        ),
      );

    // 2. Load the HTML file from assets
    _loadHtml();
  }

  Future<void> _loadHtml() async {
    // Read the file as a String
    String htmlContent = await rootBundle.loadString('assets/html/index.html');
    // Send it to the WebView
    _controller.loadHtmlString(htmlContent);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Local HTML Viewer'),
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}