import 'dart:convert';
import 'dart:io';

import 'package:docup/networking/CustomException.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiProvider {
  final String _baseUrl = "http://185.252.30.163/";

  Future<dynamic> get(String url, {Map body, bool utf8Support = false}) async {
    var responseJson;
    try {
      final headers = await getHeaders();
      final response = await http.get(_baseUrl + url, headers: headers);
      responseJson = _response(response, utf8Support: utf8Support);
    } on SocketException {
      throw FetchDataException('No Internet connection');
    }
    return responseJson;
  }

  Future<dynamic> post(String url, {Map body, bool withToken = true}) async {
    var responseJson;
    try {
      final headers = await getHeaders(withToken: withToken);
      final response = await http.post(_baseUrl + url,
          body: jsonEncode(body), headers: headers);
      responseJson = _response(response);
    } on SocketException {
      throw FetchDataException('No Internet connection');
    }
    return responseJson;
  }

  getHeaders({bool withToken = true}) async {
    final headers = {
      HttpHeaders.contentTypeHeader: "application/json",
      HttpHeaders.acceptHeader: "application/json"
    };
    if (withToken) {
      final prefs = await SharedPreferences.getInstance();
      String token = prefs.getString('token');
      if (token != null && token.isNotEmpty) {
        headers.addAll({HttpHeaders.authorizationHeader: "JWT " + token});
      }
    }
    return headers;
  }

  Future<dynamic> patch(String url, {Map body}) async {
    var responseJson;
    try {
      final headers = await getHeaders();
      final response = await http.patch(_baseUrl + url,
          body: jsonEncode(body), headers: headers);
      responseJson = _response(response);
    } on SocketException {
      throw FetchDataException('No Internet connection');
    }
    return responseJson;
  }

  dynamic _response(http.Response response, {bool utf8Support = false}) {
    switch (response.statusCode) {
      case 200:
      case 201:
        var responseJson;
        if (utf8Support) {
          responseJson = json.decode(utf8.decode(response.bodyBytes));
        } else {
          responseJson = json.decode(response.body.toString());
        }
        print(responseJson);
        return responseJson;
      case 400:
        throw BadRequestException(response.body.toString());
      case 401:

      case 403:
        throw UnauthorisedException(response.body.toString());
      case 500:

      default:
        throw FetchDataException(
            'Error occured while Communication with Server with StatusCode : ${response.statusCode}');
    }
  }
}
