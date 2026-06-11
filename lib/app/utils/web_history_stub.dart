// Stub implementation — used on Android/iOS/desktop
class WebHistory {
  static void pushState(String route) {
    // No-op on non-web platforms
  }

  static String getPathname() => '';

  static Stream<WebPopStateEvent> get onPopState =>
      const Stream.empty();
}

class WebPopStateEvent {
  const WebPopStateEvent();
}