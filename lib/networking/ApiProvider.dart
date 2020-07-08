import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:docup/networking/CustomException.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiProvider {
  static const String URL_IP = "185.252.30.163";
  final String _BASE_URL = "http://$URL_IP/";

  Future<dynamic> get(String url, {Map body, bool utf8Support = false}) async {
    var responseJson;
    try {
      final headers = await getHeaders();
      final response = await http.get(_BASE_URL + url, headers: headers);
      responseJson =
          _response(httpResponse: response, utf8Support: utf8Support);
    } on SocketException {
      throw FetchDataException('اتصال به اینترنت را بررسی کنید');
    }
    return responseJson;
  }

  Future<dynamic> postDio(String url, {FormData data}) async {
    var responseJson;
    try {
      final Map<String, dynamic> headers = {};
      final prefs = await SharedPreferences.getInstance();
      String token = prefs.getString('token');
      if (token != null && token.isNotEmpty) {
        headers.addAll({HttpHeaders.authorizationHeader: "JWT " + token});
      }
      final response = await Dio()
          .post(_BASE_URL + url, data: data, options: Options(headers: headers));
      responseJson = _response(dioResponse: response);
    } on SocketException {
      throw FetchDataException('اتصال به اینترنت را بررسی کنید');
    }
    return responseJson;
  }

  Future<dynamic> postWithBaseUrl(String baseUrl, String url,
      {Map body, bool withToken = true, bool utf8Support = false}) async {
    var responseJson;
    try {
      final headers = await getHeaders(withToken: withToken);
      final response = await http.post(baseUrl + url,
          body: jsonEncode(body), headers: headers);
      responseJson = _response(httpResponse: response, utf8Support: utf8Support);
    } on SocketException {
      throw FetchDataException('اتصال به اینترنت را بررسی کنید');
    }
    return responseJson;
  }

  Future<dynamic> post(String url, {Map body, bool withToken = true, bool utf8Support = false}) async {
    return postWithBaseUrl(_BASE_URL, url, body: body, withToken: withToken, utf8Support: utf8Support);
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
      final response = await http.patch(_BASE_URL + url,
          body: jsonEncode(body), headers: headers);
      responseJson = _response(httpResponse: response);
    } on SocketException {
      throw FetchDataException('اتصال به اینترنت را بررسی کنید');
    }
    return responseJson;
  }

  dynamic _response(
      {http.Response httpResponse,
      Response dioResponse,
      bool utf8Support = false}) {
    var response;
    if (httpResponse != null)
      response = httpResponse;
    else
      response = dioResponse;
    print(
        "API RESPONSE -->>>> code:${response.statusCode} - ${response.body.toString()}");
    switch (response.statusCode) {
      case 200:
      case 201:
        var responseJson = decodeResponse(utf8Support, response);
        print(responseJson);
        return responseJson;
      case 403:
        var responseJson = decodeResponse(utf8Support, response);
        throw ApiException(responseJson['error_code'], responseJson['detail']);
      default:
        throw ApiException(response.statusCode, "مشکلی در برقراری ارتباط وجود دارد");
    }
  }

  decodeResponse(bool utf8Support, response) {
    if (utf8Support) {
      return json.decode(utf8.decode(response.bodyBytes));
    } else {
      return json.decode(response.body.toString());
    }
  }
}
