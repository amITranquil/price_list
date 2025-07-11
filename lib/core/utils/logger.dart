// Logger utility for improved debugging and monitoring
import 'package:flutter/foundation.dart';
import 'dart:developer' as developer;

enum LogLevel {
  debug,
  info,
  warning,
  error,
  fatal,
}

class Logger {
  static const String _defaultTag = 'PriceListApp';
  
  // Prevent instantiation
  Logger._();

  /// Logs debug messages (only in debug mode)
  static void debug(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    if (kDebugMode) {
      _log(LogLevel.debug, message, tag: tag, error: error, stackTrace: stackTrace);
    }
  }

  /// Logs info messages
  static void info(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.info, message, tag: tag, error: error, stackTrace: stackTrace);
  }

  /// Logs warning messages
  static void warning(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.warning, message, tag: tag, error: error, stackTrace: stackTrace);
  }

  /// Logs error messages
  static void error(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.error, message, tag: tag, error: error, stackTrace: stackTrace);
  }

  /// Logs fatal error messages
  static void fatal(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.fatal, message, tag: tag, error: error, stackTrace: stackTrace);
  }

  /// Logs API requests
  static void apiRequest(String method, String url, {Map<String, dynamic>? params}) {
    if (kDebugMode) {
      debug('API Request: $method $url${params != null ? ' with params: $params' : ''}', tag: 'API');
    }
  }

  /// Logs API responses
  static void apiResponse(String method, String url, int statusCode, {Object? response}) {
    if (kDebugMode) {
      debug('API Response: $method $url -> $statusCode${response != null ? ' with response: $response' : ''}', tag: 'API');
    }
  }

  /// Logs database operations
  static void database(String operation, {String? table, Map<String, dynamic>? data}) {
    if (kDebugMode) {
      debug('Database: $operation${table != null ? ' on $table' : ''}${data != null ? ' with data: $data' : ''}', tag: 'DB');
    }
  }

  /// Logs navigation events
  static void navigation(String event, {String? route, Map<String, dynamic>? params}) {
    if (kDebugMode) {
      debug('Navigation: $event${route != null ? ' to $route' : ''}${params != null ? ' with params: $params' : ''}', tag: 'NAV');
    }
  }

  /// Logs state changes
  static void stateChange(String component, String oldState, String newState) {
    if (kDebugMode) {
      debug('State Change: $component from $oldState to $newState', tag: 'STATE');
    }
  }

  /// Logs performance metrics
  static void performance(String operation, Duration duration, {String? details}) {
    if (kDebugMode) {
      debug('Performance: $operation took ${duration.inMilliseconds}ms${details != null ? ' - $details' : ''}', tag: 'PERF');
    }
  }

  /// Logs validation errors
  static void validation(String field, String errorType, {String? value}) {
    if (kDebugMode) {
      debug('Validation: $field failed $errorType validation${value != null ? ' with value: $value' : ''}', tag: 'VALIDATION');
    }
  }

  /// Logs user interactions
  static void userInteraction(String action, {String? component, Map<String, dynamic>? data}) {
    if (kDebugMode) {
      debug('User Interaction: $action${component != null ? ' on $component' : ''}${data != null ? ' with data: $data' : ''}', tag: 'UI');
    }
  }

  /// Logs business logic operations
  static void business(String operation, {String? details, Map<String, dynamic>? data}) {
    if (kDebugMode) {
      debug('Business: $operation${details != null ? ' - $details' : ''}${data != null ? ' with data: $data' : ''}', tag: 'BUSINESS');
    }
  }

  /// Logs security-related events
  static void security(String event, {String? details, bool isWarning = false}) {
    if (isWarning) {
      warning('Security: $event${details != null ? ' - $details' : ''}', tag: 'SECURITY');
    } else {
      info('Security: $event${details != null ? ' - $details' : ''}', tag: 'SECURITY');
    }
  }

  /// Logs cache operations
  static void cache(String operation, {String? key, String? details}) {
    if (kDebugMode) {
      debug('Cache: $operation${key != null ? ' key: $key' : ''}${details != null ? ' - $details' : ''}', tag: 'CACHE');
    }
  }

  /// Logs file operations
  static void file(String operation, {String? path, String? details}) {
    if (kDebugMode) {
      debug('File: $operation${path != null ? ' path: $path' : ''}${details != null ? ' - $details' : ''}', tag: 'FILE');
    }
  }

  /// Internal logging method
  static void _log(
    LogLevel level,
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    final logTag = tag ?? _defaultTag;
    final timestamp = DateTime.now().toIso8601String();
    final levelName = level.name.toUpperCase();
    
    final logMessage = '[$timestamp] [$levelName] [$logTag] $message';
    
    // Use developer.log for better debugging experience
    developer.log(
      logMessage,
      name: logTag,
      level: _getLevelValue(level),
      error: error,
      stackTrace: stackTrace,
    );
    
    // Also use print for console output in debug mode
    if (kDebugMode) {
      print(logMessage);
      if (error != null) {
        print('Error: $error');
      }
      if (stackTrace != null) {
        print('Stack Trace: $stackTrace');
      }
    }
  }

  /// Gets the numeric value for log level
  static int _getLevelValue(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return 500;
      case LogLevel.info:
        return 800;
      case LogLevel.warning:
        return 900;
      case LogLevel.error:
        return 1000;
      case LogLevel.fatal:
        return 1200;
    }
  }
}

// Extension methods for easier logging
extension LoggerExtensions on Object {
  /// Logs debug message with object as tag
  void logDebug(String message, {Object? error, StackTrace? stackTrace}) {
    Logger.debug(message, tag: runtimeType.toString(), error: error, stackTrace: stackTrace);
  }

  /// Logs info message with object as tag
  void logInfo(String message, {Object? error, StackTrace? stackTrace}) {
    Logger.info(message, tag: runtimeType.toString(), error: error, stackTrace: stackTrace);
  }

  /// Logs warning message with object as tag
  void logWarning(String message, {Object? error, StackTrace? stackTrace}) {
    Logger.warning(message, tag: runtimeType.toString(), error: error, stackTrace: stackTrace);
  }

  /// Logs error message with object as tag
  void logError(String message, {Object? error, StackTrace? stackTrace}) {
    Logger.error(message, tag: runtimeType.toString(), error: error, stackTrace: stackTrace);
  }

  /// Logs fatal error message with object as tag
  void logFatal(String message, {Object? error, StackTrace? stackTrace}) {
    Logger.fatal(message, tag: runtimeType.toString(), error: error, stackTrace: stackTrace);
  }
}

// Performance timing utility
class PerformanceTimer {
  final String _operation;
  final Stopwatch _stopwatch;

  PerformanceTimer(this._operation, {String? tag}) 
    : _stopwatch = Stopwatch()..start();

  /// Stops the timer and logs the performance
  void stop({String? details}) {
    _stopwatch.stop();
    Logger.performance(_operation, _stopwatch.elapsed, details: details);
  }

  /// Gets the elapsed time without stopping
  Duration get elapsed => _stopwatch.elapsed;
}

// Utility functions for common logging patterns
class LoggingUtils {
  // Prevent instantiation
  LoggingUtils._();

  /// Times a function execution
  static T timeFunction<T>(String operation, T Function() function, {String? tag}) {
    final timer = PerformanceTimer(operation, tag: tag);
    try {
      final result = function();
      timer.stop();
      return result;
    } catch (e, stackTrace) {
      timer.stop(details: 'Failed with error: $e');
      Logger.error('Operation $operation failed', error: e, stackTrace: stackTrace, tag: tag);
      rethrow;
    }
  }

  /// Times an async function execution
  static Future<T> timeFunctionAsync<T>(String operation, Future<T> Function() function, {String? tag}) async {
    final timer = PerformanceTimer(operation, tag: tag);
    try {
      final result = await function();
      timer.stop();
      return result;
    } catch (e, stackTrace) {
      timer.stop(details: 'Failed with error: $e');
      Logger.error('Operation $operation failed', error: e, stackTrace: stackTrace, tag: tag);
      rethrow;
    }
  }

  /// Logs method entry
  static void logMethodEntry(String className, String methodName, {Map<String, dynamic>? params}) {
    if (kDebugMode) {
      Logger.debug('$className.$methodName called${params != null ? ' with params: $params' : ''}', tag: 'METHOD');
    }
  }

  /// Logs method exit
  static void logMethodExit(String className, String methodName, {dynamic returnValue}) {
    if (kDebugMode) {
      Logger.debug('$className.$methodName completed${returnValue != null ? ' with result: $returnValue' : ''}', tag: 'METHOD');
    }
  }
}

// Conditional logging based on build mode
class ConditionalLogger {
  // Prevent instantiation
  ConditionalLogger._();

  /// Only logs in debug mode
  static void debugOnly(String message, {String? tag}) {
    if (kDebugMode) {
      Logger.debug(message, tag: tag);
    }
  }

  /// Only logs in profile mode
  static void profileOnly(String message, {String? tag}) {
    if (kProfileMode) {
      Logger.info(message, tag: tag);
    }
  }

  /// Only logs in release mode
  static void releaseOnly(String message, {String? tag}) {
    if (kReleaseMode) {
      Logger.info(message, tag: tag);
    }
  }

  /// Logs in debug and profile modes
  static void devOnly(String message, {String? tag}) {
    if (kDebugMode || kProfileMode) {
      Logger.debug(message, tag: tag);
    }
  }
}