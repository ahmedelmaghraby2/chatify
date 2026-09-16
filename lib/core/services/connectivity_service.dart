import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

class ConnectivityService {
  ConnectivityService() {
    _subscription = Connectivity().onConnectivityChanged.listen((results) {
      final online = results.any((r) => r != ConnectivityResult.none);
      if (online != _isOnline) {
        _isOnline = online;
        _controller.add(_isOnline);
      }
    });
  }

  final _controller = StreamController<bool>.broadcast();
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  bool _isOnline = false;

  bool get isOnline => _isOnline;

  Stream<bool> get onConnectivityChanged => _controller.stream;

  Future<bool> checkConnectivity() async {
    final results = await Connectivity().checkConnectivity();
    _isOnline = results.any((r) => r != ConnectivityResult.none);
    return _isOnline;
  }

  @visibleForTesting
  void setOnline(bool value) {
    _isOnline = value;
  }

  Future<void> dispose() async {
    await _subscription?.cancel();
    await _controller.close();
  }
}

extension ConnectivityResultX on List<ConnectivityResult> {
  bool get isOnline => any((r) => r != ConnectivityResult.none);
}