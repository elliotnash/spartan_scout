import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'flushbar_provider.g.dart';

@riverpod
class FlushbarMessage extends _$FlushbarMessage {
  Timer? timer;
  @override
  String? build() {
    return null;
  }
  void set(String? message) {
    timer?.cancel();
    state = message;
    if (message != null) {
      timer = Timer(const Duration(seconds: 3), () {
        state = null;
      });
    }
  }
}
