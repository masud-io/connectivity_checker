import 'package:flutter_test/flutter_test.dart';
import 'package:connectivity_checker/connectivity_checker.dart';
import 'package:connectivity_checker/connectivity_checker_platform_interface.dart';
import 'package:connectivity_checker/connectivity_checker_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockConnectivityCheckerPlatform
    with MockPlatformInterfaceMixin
    implements ConnectivityCheckerPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');

  @override
  Future<bool> checkConnectivity() => Future.value(true);

  @override
  Stream<bool> get onConnectivityChanged =>
      Stream<bool>.fromIterable([true, false, true]);
}

void main() {
  final ConnectivityCheckerPlatform initialPlatform = ConnectivityCheckerPlatform.instance;

  test('$MethodChannelConnectivityChecker is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelConnectivityChecker>());
  });

  test('getPlatformVersion', () async {
    ConnectivityChecker connectivityCheckerPlugin = ConnectivityChecker();
    MockConnectivityCheckerPlatform fakePlatform = MockConnectivityCheckerPlatform();
    ConnectivityCheckerPlatform.instance = fakePlatform;

    expect(await connectivityCheckerPlugin.getPlatformVersion(), '42');
  });

  test('checkConnectivity returns connectivity status', () async {
    ConnectivityChecker connectivityCheckerPlugin = ConnectivityChecker();
    MockConnectivityCheckerPlatform fakePlatform = MockConnectivityCheckerPlatform();
    ConnectivityCheckerPlatform.instance = fakePlatform;

    final status = await connectivityCheckerPlugin.checkConnectivity();
    expect(status, ConnectivityStatus.connected);
  });

  test('onConnectivityChanged emits status changes', () async {
    ConnectivityChecker connectivityCheckerPlugin = ConnectivityChecker();
    MockConnectivityCheckerPlatform fakePlatform = MockConnectivityCheckerPlatform();
    ConnectivityCheckerPlatform.instance = fakePlatform;

    expectLater(
        connectivityCheckerPlugin.onConnectivityChanged,
        emitsInOrder([
          ConnectivityStatus.connected,
          ConnectivityStatus.disconnected,
          ConnectivityStatus.connected
        ])
    );
  });
}