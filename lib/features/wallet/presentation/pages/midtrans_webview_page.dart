import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../../core/app_colors.dart';

/// Hosts the Midtrans Snap payment page in a WebView.
/// Pops `true` when Snap reaches a finish/close redirect.
class MidtransWebViewPage extends StatefulWidget {
  final String redirectUrl;
  const MidtransWebViewPage({super.key, required this.redirectUrl});

  @override
  State<MidtransWebViewPage> createState() => _MidtransWebViewPageState();
}

class _MidtransWebViewPageState extends State<MidtransWebViewPage> {
  late final WebViewController _controller;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) => setState(() => _loading = true),
          onPageFinished: (_) => setState(() => _loading = false),
          onNavigationRequest: (request) {
            final url = request.url;
            // Snap redirects to your configured Finish/Error/Unfinished URLs.
            // Set those in the Midtrans dashboard to a known host you can match.
            if (url.contains('koopcare.finish') ||
                url.contains('transaction_status') ||
                url.contains('status_code')) {
              Navigator.of(context).pop(true);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.redirectUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kScaffold,
      appBar: AppBar(
        backgroundColor: kScaffold,
        elevation: 0,
        foregroundColor: const Color(0xFF1D2E14),
        title: const Text(
          'Pembayaran',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(false),
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_loading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
