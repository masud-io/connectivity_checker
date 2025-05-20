// File: README.md
# connectivity_checker

A Flutter package for checking internet connectivity on Android and iOS platforms.

## Features

- Check current internet connectivity status
- Listen for connectivity changes in real-time
- Verify actual internet availability with ping tests
- Support for both Android and iOS platforms

## Getting Started

Add the package to your pubspec.yaml:

```yaml
dependencies:
  connectivity_checker:
  git:
    url: https://github.com/mmh-masud-03/connectivity_checker.git
    ref: master


```

Then run:

```
flutter pub get
```

## Usage

### Basic Usage

```dart
import 'package:connectivity_checker/connectivity_checker.dart';

// Create an instance
final connectivityChecker = ConnectivityChecker();

// Check current connectivity status
final status = await connectivityChecker.checkConnectivity();
print('Current status: $status');

// Check if internet is actually available
final isAvailable = await connectivityChecker.isInternetAvailable();
print('Internet available: $isAvailable');

// Listen for connectivity changes
connectivityChecker.onConnectivityChanged.listen((status) {
  print('Connectivity changed: $status');
});

// Dispose when done
connectivityChecker.dispose();
```

### Advanced Usage

You can customize the internet availability check:

```dart
// Change the host to ping and the timeout duration
final isAvailable = await connectivityChecker.isInternetAvailable(
  host: 'apple.com',
  timeout: const Duration(seconds: 5),
);
```

## Example App

Check the example directory for a complete demo application showing how to use this package.

## Platform Specifics

### Android

The plugin uses `ConnectivityManager` and `NetworkCallback` to detect connectivity changes.

### iOS

For iOS 12 and above, the plugin uses `NWPathMonitor` to detect connectivity changes.
For older iOS versions, it falls back to using `SCNetworkReachability`.

## License

This project is licensed under the MIT License - see the LICENSE file for details.