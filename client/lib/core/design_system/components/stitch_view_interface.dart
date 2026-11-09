import 'package:flutter/widgets.dart';

typedef OnStitchMessageCallback = void Function(Map<String, dynamic> message);

abstract class StitchViewPlatform {
  Widget buildView({
    required int screenIndex,
    required String initialUrl,
    required OnStitchMessageCallback onMessage,
  });
}

