package com.example.connectivity_checker

import android.content.Context
import android.net.ConnectivityManager
import android.net.Network
import android.net.NetworkCapabilities
import android.net.NetworkRequest
import android.os.Build
import android.os.Handler
import android.os.Looper
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

class ConnectivityCheckerPlugin: FlutterPlugin, MethodCallHandler, EventChannel.StreamHandler {
  private lateinit var methodChannel: MethodChannel
  private lateinit var eventChannel: EventChannel
  private lateinit var context: Context
  private var connectivityManager: ConnectivityManager? = null
  private var networkCallback: ConnectivityManager.NetworkCallback? = null
  private var eventSink: EventChannel.EventSink? = null
  private val mainHandler = Handler(Looper.getMainLooper())

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    context = flutterPluginBinding.applicationContext
    connectivityManager = context.getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager

    methodChannel = MethodChannel(flutterPluginBinding.binaryMessenger, "connectivity_checker")
    eventChannel = EventChannel(flutterPluginBinding.binaryMessenger, "connectivity_checker/connectivity_status")

    methodChannel.setMethodCallHandler(this)
    eventChannel.setStreamHandler(this)
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    when (call.method) {
      "checkConnectivity" -> {
        result.success(getConnectivityStatus())
      }
      else -> {
        result.notImplemented()
      }
    }
  }

  override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
    eventSink = events
    registerNetworkCallback()

    // Send initial status on main thread
    mainHandler.post {
      eventSink?.success(getConnectivityStatus())
    }
  }

  override fun onCancel(arguments: Any?) {
    unregisterNetworkCallback()
    eventSink = null
  }

  private fun registerNetworkCallback() {
    if (networkCallback != null) return

    networkCallback = object : ConnectivityManager.NetworkCallback() {
      override fun onAvailable(network: Network) {
        mainHandler.post {
          eventSink?.success("connected")
        }
      }

      override fun onLost(network: Network) {
        mainHandler.post {
          // Only emit disconnected if there's no other available network
          if (!isNetworkAvailable()) {
            eventSink?.success("disconnected")
          }
        }
      }
    }

    val networkRequest = NetworkRequest.Builder()
      .addCapability(NetworkCapabilities.NET_CAPABILITY_INTERNET)
      .build()

    connectivityManager?.registerNetworkCallback(networkRequest, networkCallback!!)
  }

  private fun unregisterNetworkCallback() {
    networkCallback?.let {
      connectivityManager?.unregisterNetworkCallback(it)
      networkCallback = null
    }
  }

  private fun isNetworkAvailable(): Boolean {
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
      val networkCapabilities = connectivityManager?.getNetworkCapabilities(connectivityManager?.activeNetwork)
      return networkCapabilities != null &&
              networkCapabilities.hasCapability(NetworkCapabilities.NET_CAPABILITY_INTERNET)
    } else {
      @Suppress("DEPRECATION")
      val activeNetworkInfo = connectivityManager?.activeNetworkInfo
      @Suppress("DEPRECATION")
      return activeNetworkInfo != null && activeNetworkInfo.isConnected
    }
  }

  private fun getConnectivityStatus(): String {
    return if (isNetworkAvailable()) "connected" else "disconnected"
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    unregisterNetworkCallback()
    methodChannel.setMethodCallHandler(null)
    eventChannel.setStreamHandler(null)
  }
}