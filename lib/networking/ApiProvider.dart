import 'dart:convert';
import 'dart:io';

import 'package:Neuronio/networking/CustomException.dart';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiProvider {
  static const String URL_IP = "185.252.30.163";
  static const String Host = "http://$URL_IP";
  final String _baseURL = "http://$URL_IP/";

  static String getURLParametersString(Map<String, dynamic> params) {
    List<String> paramList = [];
    params.forEach((key, value) {
      paramList.add(key + "=" + value.toString());
    });
    return paramList.join("&");
  }

  Future<dynamic> get(String url, {bool utf8Support = false}) async {
    var responseJson;
    try {
      final headers = await getHeaders();
      print(_baseURL + url);
      final response = await http.get(_baseURL + url, headers: headers);
      responseJson =
          _response(httpResponse: response, utf8Support: utf8Support);
    } on SocketException {
      throw FetchDataException('اتصال به اینترنت را بررسی کنید');
    }
    return responseJson;
  }

  Future<dynamic> getWithBaseUrl(String url,
      {Map body, bool utf8Support = false}) async {
    var responseJson;
    try {
      final headers = await getHeaders();
      print(url);
      final response = await http.get(url, headers: headers);
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
      print(_baseURL + url);
      final response = await Dio()
          .post(_baseURL + url, data: data, options: Options(headers: headers));
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
      print(_baseURL + url);
      final response = await http.post(baseUrl + url,
          body: jsonEncode(body), headers: headers);
      responseJson =
          _response(httpResponse: response, utf8Support: utf8Support);
    } on SocketException {
      throw FetchDataException('اتصال به اینترنت را بررسی کنید');
    }
    return responseJson;
  }

  Future<dynamic> post(String url,
      {Map body, bool withToken = true, bool utf8Support = false}) async {
    return postWithBaseUrl(_baseURL, url,
        body: body, withToken: withToken, utf8Support: utf8Support);
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
      print(_baseURL + url);
      final response = await http.patch(_baseURL + url,
          body: jsonEncode(body), headers: headers);
      responseJson = _response(httpResponse: response);
    } on SocketException {
      throw FetchDataException('اتصال به اینترنت را بررسی کنید');
    }
    return responseJson;
  }

  Future<dynamic> delete(String url) async {
    var responseJson;
    try {
      final headers = await getHeaders();
      print(_baseURL + url);
      final response = await http.delete(_baseURL + url, headers: headers);
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
    String body = "";
    try {
      body = utf8.decode(response.body.toString().codeUnits);
    } catch (e) {
      body = response.body.toString();
    }
    switch (response.statusCode) {
      case 200:
      case 201:
        var responseJson = decodeResponse(utf8Support, response);
        return responseJson;
      case 403:
      case 400:
      case 404:
        var responseJson = decodeResponse(utf8Support, response);
        print("API RESPONSE -->>>> code:${response.statusCode} - $body");

        /// some changes happened in backend and error_code became code and detail became msg
        throw ApiException(
            responseJson['error_code'] ?? responseJson['code'] ?? 404,
            responseJson['detail'] ??
                responseJson['msg'] ??
                (responseJson['non_field_errors'] != null
                    ? responseJson['non_field_errors'][0]
                    : responseJson.toString()));
      default:
        print("API RESPONSE -->>>> code:${response.statusCode} - ${body}");
        throw ApiException(
            response.statusCode, "مشکلی در برقراری ارتباط وجود دارد");
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
