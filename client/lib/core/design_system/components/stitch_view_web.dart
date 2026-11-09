import 'dart:convert';
import 'dart:js_interop';
import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;
import 'stitch_view_interface.dart';

StitchViewPlatform getStitchViewPlatform() => _StitchViewWeb();

class _StitchViewWeb implements StitchViewPlatform {
  static final Set<String> _registeredTypes = {};

  @override
  Widget buildView({
    required int screenIndex,
    required String initialUrl,
    required OnStitchMessageCallback onMessage,
  }) {
    return _StitchWebWidget(
      screenIndex: screenIndex,
      initialUrl: initialUrl,
      onMessage: onMessage,
    );
  }
}

class _StitchWebWidget extends StatefulWidget {
  final int screenIndex;
  final String initialUrl;
  final OnStitchMessageCallback onMessage;

  const _StitchWebWidget({
    required this.screenIndex,
    required this.initialUrl,
    required this.onMessage,
  });

  @override
  State<_StitchWebWidget> createState() => _StitchWebWidgetState();
}

class _StitchWebWidgetState extends State<_StitchWebWidget> {
  late final String _viewType;
  JSFunction? _messageListener;

  @override
  void initState() {
    super.initState();
    _viewType = 'stitch-screen-${widget.screenIndex}';

    if (!_StitchViewWeb._registeredTypes.contains(_viewType)) {
      _StitchViewWeb._registeredTypes.add(_viewType);
      ui_web.platformViewRegistry.registerViewFactory(
        _viewType,
        (int viewId) {
          final iframe = web.HTMLIFrameElement()
            ..src = widget.initialUrl
            ..style.border = 'none'
            ..style.width = '100%'
            ..style.height = '100%'
            ..style.overflow = 'auto';
          return iframe;
        },
      );
    }

    _setupListener();
  }

  void _setupListener() {
    _messageListener = ((web.MessageEvent event) {
      try {
        final data = event.data;
        if (data != null) {
          final dartified = data.dartify();
          if (dartified is Map) {
            widget.onMessage(Map<String, dynamic>.from(dartified));
          } else if (dartified is String) {
            try {
              final decoded = jsonDecode(dartified);
              if (decoded is Map<String, dynamic>) {
                widget.onMessage(decoded);
              }
            } catch (_) {}
          }
        }
      } catch (e) {
        // Ignored non-json messages
      }
    }).toJS;

    web.window.addEventListener('message', _messageListener!);
  }

  @override
  void dispose() {
    if (_messageListener != null) {
      web.window.removeEventListener('message', _messageListener!);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return HtmlElementView(viewType: _viewType);
  }
}
