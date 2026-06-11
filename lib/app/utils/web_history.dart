// Conditional export — Dart picks the right file at compile time
export 'web_history_stub.dart' if (dart.library.html) 'web_history_web.dart';