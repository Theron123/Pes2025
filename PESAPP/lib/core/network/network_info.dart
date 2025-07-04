import 'dart:async';
import 'dart:io';

/// Network connectivity information and utilities
abstract class NetworkInfo {
  Future<bool> get isConnected;
  Stream<bool> get onConnectivityChanged;
}

/// Implementation of NetworkInfo using basic connectivity checks
class NetworkInfoImpl implements NetworkInfo {
  static const String _testUrl = 'google.com';
  static const int _testPort = 53;
  static const Duration _timeout = Duration(seconds: 3);

  final StreamController<bool> _connectivityController = StreamController<bool>.broadcast();
  Timer? _periodicCheck;
  bool _lastKnownStatus = false;

  NetworkInfoImpl() {
    _startPeriodicCheck();
  }

  @override
  Future<bool> get isConnected async {
    try {
      final result = await InternetAddress.lookup(_testUrl);
      final connected = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
      _updateStatus(connected);
      return connected;
    } catch (e) {
      _updateStatus(false);
      return false;
    }
  }

  @override
  Stream<bool> get onConnectivityChanged => _connectivityController.stream;

  /// Start periodic connectivity checks
  void _startPeriodicCheck() {
    _periodicCheck = Timer.periodic(const Duration(seconds: 10), (_) async {
      final connected = await isConnected;
      if (connected != _lastKnownStatus) {
        _updateStatus(connected);
      }
    });
  }

  /// Update connectivity status and notify listeners
  void _updateStatus(bool isConnected) {
    if (_lastKnownStatus != isConnected) {
      _lastKnownStatus = isConnected;
      _connectivityController.add(isConnected);
    }
  }

  /// Stop periodic checks and close streams
  void dispose() {
    _periodicCheck?.cancel();
    _connectivityController.close();
  }

  /// Test connection to specific host
  static Future<bool> testConnection(String host, {int port = 80, Duration? timeout}) async {
    try {
      final socket = await Socket.connect(
        host,
        port,
        timeout: timeout ?? _timeout,
      );
      socket.destroy();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Test connection to Supabase specifically
  static Future<bool> testSupabaseConnection(String supabaseUrl) async {
    try {
      // Extract host from URL
      final uri = Uri.parse(supabaseUrl);
      final host = uri.host;
      
      // Test HTTPS connection (port 443)
      return await testConnection(host, port: 443, timeout: _timeout);
    } catch (e) {
      return false;
    }
  }

  /// Get network connection quality (rough estimate)
  static Future<NetworkQuality> getConnectionQuality() async {
    final stopwatch = Stopwatch()..start();
    
    try {
      final result = await InternetAddress.lookup(_testUrl);
      stopwatch.stop();
      
      if (result.isEmpty) {
        return NetworkQuality.none;
      }
      
      final latency = stopwatch.elapsedMilliseconds;
      
      if (latency < 100) {
        return NetworkQuality.excellent;
      } else if (latency < 300) {
        return NetworkQuality.good;
      } else if (latency < 600) {
        return NetworkQuality.fair;
      } else {
        return NetworkQuality.poor;
      }
    } catch (e) {
      return NetworkQuality.none;
    }
  }
}

/// Network quality levels
enum NetworkQuality {
  none,
  poor,
  fair,
  good,
  excellent;

  /// Get human-readable description
  String get description {
    switch (this) {
      case NetworkQuality.none:
        return 'No Connection';
      case NetworkQuality.poor:
        return 'Poor Connection';
      case NetworkQuality.fair:
        return 'Fair Connection';
      case NetworkQuality.good:
        return 'Good Connection';
      case NetworkQuality.excellent:
        return 'Excellent Connection';
    }
  }

  /// Get connection quality color indicator
  int get colorValue {
    switch (this) {
      case NetworkQuality.none:
        return 0xFFF44336; // Red
      case NetworkQuality.poor:
        return 0xFFFF9800; // Orange
      case NetworkQuality.fair:
        return 0xFFFFEB3B; // Yellow
      case NetworkQuality.good:
        return 0xFF8BC34A; // Light Green
      case NetworkQuality.excellent:
        return 0xFF4CAF50; // Green
    }
  }

  /// Check if connection is sufficient for basic operations
  bool get isSufficient => this != NetworkQuality.none;

  /// Check if connection is good enough for file operations
  bool get isGoodForFiles => index >= NetworkQuality.fair.index;

  /// Check if connection is good enough for real-time features
  bool get isGoodForRealtime => index >= NetworkQuality.good.index;
}

/// Network status information
class NetworkStatus {
  final bool isConnected;
  final NetworkQuality quality;
  final DateTime timestamp;

  const NetworkStatus({
    required this.isConnected,
    required this.quality,
    required this.timestamp,
  });

  /// Check if status is recent (within last 30 seconds)
  bool get isRecent {
    final now = DateTime.now();
    return now.difference(timestamp).inSeconds < 30;
  }

  @override
  String toString() {
    return 'NetworkStatus(connected: $isConnected, quality: ${quality.description}, time: $timestamp)';
  }
}

/// Network utilities for the hospital system
class HospitalNetworkUtils {
  /// Check if network is suitable for appointment operations
  static Future<bool> canPerformAppointmentOperations() async {
    final quality = await NetworkInfoImpl.getConnectionQuality();
    return quality.isSufficient;
  }

  /// Check if network is suitable for report generation
  static Future<bool> canGenerateReports() async {
    final quality = await NetworkInfoImpl.getConnectionQuality();
    return quality.isGoodForFiles;
  }

  /// Check if network is suitable for real-time notifications
  static Future<bool> canReceiveRealTimeNotifications() async {
    final quality = await NetworkInfoImpl.getConnectionQuality();
    return quality.isGoodForRealtime;
  }

  /// Get recommended retry delay based on network quality
  static Duration getRetryDelay(NetworkQuality quality) {
    switch (quality) {
      case NetworkQuality.none:
        return const Duration(seconds: 30);
      case NetworkQuality.poor:
        return const Duration(seconds: 10);
      case NetworkQuality.fair:
        return const Duration(seconds: 5);
      case NetworkQuality.good:
        return const Duration(seconds: 2);
      case NetworkQuality.excellent:
        return const Duration(seconds: 1);
    }
  }
} 