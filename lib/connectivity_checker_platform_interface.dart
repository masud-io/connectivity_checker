import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'connectivity_checker_method_channel.dart';

abstract class ConnectivityCheckerPlatform extends PlatformInterface {
  /// Constructs a ConnectivityCheckerPlatform.
  ConnectivityCheckerPlatform() : super(token: _token);

  static final Object _token = Object();

  static ConnectivityCheckerPlatform _instance = MethodChannelConnectivityChecker();

  /// The default instance of [ConnectivityCheckerPlatform] to use.
  static ConnectivityCheckerPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [ConnectivityCheckerPlatform] when
  /// they register themselves.
  static set instance(ConnectivityCheckerPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  /// Checks the current connectivity status
  Future<bool> checkConnectivity() {
    throw UnimplementedError('checkConnectivity() has not been implemented.');
  }

  /// Stream of connectivity status changes
  Stream<bool> get onConnectivityChanged {
    throw UnimplementedError('onConnectivityChanged has not been implemented.');
  }
}