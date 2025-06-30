import 'dart:convert';
import 'package:http/http.dart' as http;

class RemoteConfig {
  static const String url =
      'https://raw.githubusercontent.com/jcjm01/conversor/main/estado_app.json';

  static Future<Map<String, dynamic>> obtenerEstadoApp() async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al cargar estado desde el servidor');
    }
  }
}
