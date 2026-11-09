import 'package:flutter/material.dart';
import 'stitch_view_interface.dart';

StitchViewPlatform getStitchViewPlatform() => _StitchViewStub();

class _StitchViewStub implements StitchViewPlatform {
  @override
  Widget buildView({
    required int screenIndex,
    required String initialUrl,
    required OnStitchMessageCallback onMessage,
  }) {
    return Center(
      child: Text('Stitch Screen $screenIndex (Platform Stub)'),
    );
  }
}

