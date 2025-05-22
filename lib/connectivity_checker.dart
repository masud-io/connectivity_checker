import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';


// Add this enum for connectivity status
enum ConnectivityStatus {
  /// Connected to the internet
  connected,

  /// Not connected to the internet
  disconnected,

  /// Status is currently unknown
  unknown
}


class ConnectivityChecker {
  // Method channel for invoking platform methods
  static const MethodChannel _channel = MethodChannel('connectivity_checker');

  // Event channel for streaming connectivity changes
  static const EventChannel _eventChannel = EventChannel('connectivity_checker/connectivity_status');

  // Stream controller for connectivity status changes
  final StreamController<ConnectivityStatus> _connectionStatusController =
  StreamController<ConnectivityStatus>.broadcast();

  // Stream of connectivity status changes
  Stream<ConnectivityStatus> get onConnectivityChanged => _connectionStatusController.stream;

  // Singleton instance
  static final ConnectivityChecker _instance = ConnectivityChecker._internal();

  // Factory constructor
  factory ConnectivityChecker() => _instance;

  // Private constructor
  ConnectivityChecker._internal() {
    // Initialize connection status monitoring
    _initConnectivityListener();
  }

  // Initialize the connectivity listener
  void _initConnectivityListener() {
    _eventChannel.receiveBroadcastStream().listen((dynamic event) {
      ConnectivityStatus status = _convertToStatus(event);
      _connectionStatusController.add(status);
    });
  }

  // Convert platform-specific status to our enum
  ConnectivityStatus _convertToStatus(dynamic status) {
    if (status == 'connected') {
      return ConnectivityStatus.connected;
    } else if (status == 'disconnected') {
      return ConnectivityStatus.disconnected;
    } else {
      return ConnectivityStatus.unknown;
    }
  }

  // Check the current connectivity status
  Future<ConnectivityStatus> checkConnectivity() async {
    try {
      final String result = await _channel.invokeMethod('checkConnectivity');
      return _convertToStatus(result);
    } on PlatformException catch (_) {
      return ConnectivityStatus.unknown;
    }
  }

  Future<String?> getPlatformVersion() async {
    try {
      final String result = await _channel.invokeMethod('getPlatformVersion');
      return result;
    } on PlatformException catch (_) {
      return null;
    }
  }

  // Check if there is an active internet connection by pinging a reliable host
  Future<bool> isInternetAvailable({String host = 'google.com', Duration timeout = const Duration(seconds: 3)}) async {
    try {
      final result = await InternetAddress.lookup(host)
          .timeout(timeout);
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    } on TimeoutException catch (_) {
      return false;
    }
  }

  // Dispose the stream controller
  void dispose() {
    _connectionStatusController.close();
  }
}