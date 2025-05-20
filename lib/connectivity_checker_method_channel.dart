import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'connectivity_checker_platform_interface.dart';

/// An implementation of [ConnectivityCheckerPlatform] that uses method channels.
class MethodChannelConnectivityChecker extends ConnectivityCheckerPlatform {
  @visibleForTesting
  final methodChannel = const MethodChannel('connectivity_checker');
  final _connectivityStatusStream = const EventChannel('connectivity_checker/connectivity_status')
      .receiveBroadcastStream()
      .map((event) => event == 'connected');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  Future<bool> checkConnectivity() async {
    final result = await methodChannel.invokeMethod<bool>('checkConnectivity');
    return result ?? false;
  }

  @override
  Stream<bool> get onConnectivityChanged => _connectivityStatusStream;
}