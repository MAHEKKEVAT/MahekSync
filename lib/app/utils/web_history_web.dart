// Web implementation — only compiled for web targets
import 'dart:html' as html;

class WebHistory {
  static void pushState(String route) {
    html.window.history.pushState(null, '', route);
  }

  static String getPathname() => html.window.location.pathname ?? '';

  static Stream<WebPopStateEvent> get onPopState =>
      html.window.onPopState.map((_) => const WebPopStateEvent());
}

class WebPopStateEvent {
  const WebPopStateEvent();
}