// internet_check_mobile.dart
import 'package:http/http.dart' as http;

Future<bool> hasInternetConnection() async {
  try {
    final response = await http.head(Uri.parse('https://example.com'));
    return response.statusCode >= 200 && response.statusCode < 400;
  } catch (_) {
    return false;
  }
}