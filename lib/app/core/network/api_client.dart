import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';

class LoggingClient extends http.BaseClient {
  final http.Client _inner = http.Client();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    if (kDebugMode) {
      print('================ HTTP REQUEST ================');
      print('${request.method} ${request.url}');
      print('Headers: ${request.headers}');
      if (request is http.Request) {
        print('Body: ${request.body}');
      }
      print('==============================================');
    }

    final response = await _inner.send(request);

    if (kDebugMode) {
      final responseBody = await response.stream.bytesToString();
      print('================ HTTP RESPONSE ===============');
      print('${request.method} ${request.url}');
      print('Status Code: ${response.statusCode}');
      print('Body: $responseBody');
      print('==============================================');
      
      // We must return a new StreamedResponse because the original stream was consumed
      return http.StreamedResponse(
        Stream.value(utf8.encode(responseBody)),
        response.statusCode,
        contentLength: utf8.encode(responseBody).length,
        request: request,
        headers: response.headers,
        isRedirect: response.isRedirect,
        persistentConnection: response.persistentConnection,
        reasonPhrase: response.reasonPhrase,
      );
    }
    return response;
  }
}

final apiClient = LoggingClient();
