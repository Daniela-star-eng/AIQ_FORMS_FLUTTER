// internet_check_web.dart
import 'dart:html' as html;

Future<bool?> hasInternetConnection() async {
  return html.window.navigator.onLine;
}