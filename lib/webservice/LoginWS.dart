import 'package:http/http.dart' as http;

Future<http.Response> login() async {
  final response = await http.get('localhost:8000/api/auth/login/');

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response, then parse the JSON.
//    return Album.fromJson(json.decode(response.body));
  } else {
    // If the server did not return a 200 OK response, then throw an exception.
    throw Exception('Failed to load album');
  }
}
