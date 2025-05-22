import Flutter
import UIKit
import Network
import SystemConfiguration

public class ConnectivityCheckerPlugin: NSObject, FlutterPlugin, FlutterStreamHandler {
  private var eventSink: FlutterEventSink?
  private var networkMonitor: NWPathMonitor?

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "connectivity_checker", binaryMessenger: registrar.messenger())
    let eventChannel = FlutterEventChannel(name: "connectivity_checker/connectivity_status", binaryMessenger: registrar.messenger())
    let instance = ConnectivityCheckerPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
    eventChannel.setStreamHandler(instance)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getPlatformVersion":
      result("iOS " + UIDevice.current.systemVersion)
    case "checkConnectivity":
      result(isConnected() ? "connected" : "disconnected")
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    eventSink = events
    startMonitoring()

    // Send initial state
    eventSink?(isConnected() ? "connected" : "disconnected")
    return nil
  }

  public func onCancel(withArguments arguments: Any?) -> FlutterError? {
    stopMonitoring()
    eventSink = nil
    return nil
  }

  private func startMonitoring() {
    if #available(iOS 12.0, *) {
      networkMonitor = NWPathMonitor()
      let queue = DispatchQueue.global(qos: .background)
      networkMonitor?.start(queue: queue)

      networkMonitor?.pathUpdateHandler = { [weak self] path in
        let status = path.status == .satisfied ? "connected" : "disconnected"
        DispatchQueue.main.async {
          self?.eventSink?(status)
        }
      }
    }
  }

  private func stopMonitoring() {
    if #available(iOS 12.0, *) {
      networkMonitor?.cancel()
      networkMonitor = nil
    }
  }

  private func isConnected() -> Bool {
    if #available(iOS 12.0, *) {
      guard let monitor = networkMonitor else {
        return checkConnectionReachability()
      }
      return monitor.currentPath.status == .satisfied
    } else {
      return checkConnectionReachability()
    }
  }

  // This method is referenced but not implemented in your code
  private func checkConnectionReachability() -> Bool {
    var zeroAddress = sockaddr_in()
    zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
    zeroAddress.sin_family = sa_family_t(AF_INET)

    let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
      $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
        SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
      }
    }

    var flags: SCNetworkReachabilityFlags = []
    if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
      return false
    }

    let isReachable = flags.contains(.reachable)
    let needsConnection = flags.contains(.connectionRequired)

    return isReachable && !needsConnection
  }
}