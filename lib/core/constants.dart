class AppConstants {
  // App name
  static const String appName = 'VibeCalc';

  // Max history entries to keep
  static const int maxHistory = 100;

  // Display precision (significant digits)
  static const int displayPrecision = 10;

  // Graph resolution (number of points)
  static const int graphResolution = 220;

  // Default graph x-range
  static const double defaultMinX = -10.0;
  static const double defaultMaxX = 10.0;

  // Number of axis divisions on the graph
  static const int graphAxisDivisions = 5;

  // Swipe velocity threshold to trigger backspace in DisplayPanel
  static const double swipeDeleteVelocity = 300.0;
}