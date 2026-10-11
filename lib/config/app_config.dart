/// Application Configuration & Constants
///
/// This file centralizes configurable app values (e.g. feedback email, demo user).
/// Sensitive values are kept generic here so that no personal emails or secrets
/// are exposed when uploading to GitHub.
class AppConfig {
  /// The feedback email destination.
  /// Change this to your desired recipient email when running locally.
  static const String feedbackEmail = 'support@example.com';

  /// Fallback demo email used in offline / guest preview mode.
  static const String demoUserEmail = 'user@example.com';

  /// App Display Title
  static const String appName = 'FireTask';
}
