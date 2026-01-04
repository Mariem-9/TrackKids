import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../services/activity_logger.dart';
import '../../../core/constants/app_colors.dart';

class SafeBrowserPage extends StatefulWidget {
  final String childId;
  const SafeBrowserPage({super.key, required this.childId});

  @override
  State<SafeBrowserPage> createState() => _SafeBrowserPageState();
}

class _SafeBrowserPageState extends State<SafeBrowserPage> {
  late final Stream<DocumentSnapshot> _blockedSitesStream;
  late WebViewController _controller;

  List<String> blockedSites = [];
  String currentUrl = "https://google.com";

  @override
  void initState() {
    super.initState();

    // Stream pour suivre les sites bloqués en temps réel
    _blockedSitesStream = FirebaseFirestore.instance
        .collection('children')
        .doc(widget.childId)
        .snapshots();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (request) {
            final url = request.url;

            if (_isBlocked(url)) {
              // Log blocked
              ActivityLogger.log(
                childId: widget.childId,
                url: url,
                action: 'blocked',
              );

              // Charger page site bloqué
              _controller.loadHtmlString(
                "<h1 style='text-align:center;margin-top:50%'>⛔ Site bloqué</h1>",
              );

              return NavigationDecision.prevent;
            }

            // Log allowed
            ActivityLogger.log(
              childId: widget.childId,
              url: url,
              action: 'allowed',
            );

            return NavigationDecision.navigate;
          },
          onPageFinished: (url) {
            // Aussi log à la fin du chargement pour capter les redirections
            if (!_isBlocked(url)) {
              ActivityLogger.log(
                childId: widget.childId,
                url: url,
                action: 'allowed',
              );
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(currentUrl));
  }

  bool _isBlocked(String url) {
    return blockedSites.any((site) => url.contains(site));
  }

  void _loadUrl(String url) {
    if (!url.startsWith("http")) {
      url = "https://$url";
    }
    setState(() {
      currentUrl = url;
    });
    _controller.loadRequest(Uri.parse(currentUrl));
  }

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<ProjectColors>()!;

    final TextEditingController urlController =
    TextEditingController(text: currentUrl);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Safe Browser'),
        backgroundColor: palette.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () async {
              if (await _controller.canGoBack()) _controller.goBack();
            },
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward),
            onPressed: () async {
              if (await _controller.canGoForward()) _controller.goForward();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: urlController,
                    decoration: const InputDecoration(
                      hintText: 'Entrer une URL',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    onSubmitted: _loadUrl,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_right_alt),
                  onPressed: () => _loadUrl(urlController.text),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<DocumentSnapshot>(
              stream: _blockedSitesStream,
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data!.exists) {
                  final data = snapshot.data!.data() as Map<String, dynamic>;
                  blockedSites = List<String>.from(data['blockedSites'] ?? []);
                }
                return WebViewWidget(controller: _controller);
              },
            ),
          ),
        ],
      ),
    );
  }
}


/*import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../services/activity_logger.dart';
import '../../../core/constants/app_colors.dart';
import 'dart:io';


class SafeBrowserPage extends StatefulWidget {
  final String childId;
  const SafeBrowserPage({super.key, required this.childId});

  @override
  State<SafeBrowserPage> createState() => _SafeBrowserPageState();
}


class _SafeBrowserPageState extends State<SafeBrowserPage> {
  List<String> blockedSites = [];
  late final Stream<DocumentSnapshot> _blockedSitesStream;

  @override
  void initState() {
    super.initState();
    // Utiliser un stream pour que la liste soit toujours à jour
    _blockedSitesStream = FirebaseFirestore.instance
        .collection('children')
        .doc(widget.childId)
        .snapshots();
  }

  bool _isBlocked(String url) {
    return blockedSites.any((site) => url.contains(site));
  }

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<ProjectColors>()!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Safe Browser'),
        backgroundColor: palette.primary,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _blockedSitesStream,
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data!.exists) {
            final data = snapshot.data!.data() as Map<String, dynamic>;
            blockedSites = List<String>.from(data['blockedSites'] ?? []);
          }

          return WebView(
            initialUrl: 'https://google.com',
            javascriptMode: JavascriptMode.unrestricted,
            navigationDelegate: (request) {
              if (_isBlocked(request.url)) {
                ActivityLogger.log(
                  childId: widget.childId,
                  url: request.url,
                  action: 'blocked',
                );

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('⛔ Site bloqué')),
                );

                return NavigationDecision.prevent;
              }

              ActivityLogger.log(
                childId: widget.childId,
                url: request.url,
                action: 'allowed',
              );

              return NavigationDecision.navigate;
            },
          );
        },
      ),
    );
  }
}*/
