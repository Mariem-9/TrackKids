
class ShowLogger {
  /// Print a log message to console with a timestamp
  static void log(String message) {
    final timestamp = DateTime.now().toIso8601String();
    print('[TrackKids][$timestamp] $message');
  }

}
