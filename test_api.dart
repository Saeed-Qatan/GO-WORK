import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  try {
    final response = await http.get(Uri.parse('https://api.masarak.app/api/Jobs/2'));
    print('Status: ${response.statusCode}');
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final json = jsonDecode(response.body);
      print('Skills exists: ${json['data'] != null && json['data']['skills'] != null}');
      if (json['data'] != null && json['data']['skills'] != null) {
        print('Skills type: ${json['data']['skills'].runtimeType}');
        print('Skills: ${json['data']['skills']}');
      }
    } else {
      print('Response: ${response.body}');
    }
  } catch (e) {
    print('Error: $e');
  }
}
