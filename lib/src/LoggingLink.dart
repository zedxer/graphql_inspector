import 'dart:convert';
import 'dart:developer';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:gql/language.dart' show printNode;
class LoggingLink extends Link {
  final Link innerLink;
  final String url;
  final dynamic headers;

  LoggingLink({required this.innerLink, required this.url, required this.headers });

  @override
  Stream<Response> request(Request request, [NextLink? forward]) {
    final query = request.operation.document;
    final rawQuery = printNode(query);
    final variables = request.variables;

    log("📤 GraphQL Request:\n$rawQuery\nVariables: ${_prettyJson(variables)}");
    // Optional: Save logs
    GQLLogger().log(rawQuery, variables, url, headers);
    final stream = innerLink.request(request, forward);

    return stream.map((response) {
      log("📥 GraphQL Response:\n${response.data}");

      GQLLogger().updateLastResponse(_prettyJson(response.data));
      return response;
    });
  }
  String _prettyJson(dynamic input) {
    try {
      return const JsonEncoder.withIndent('  ').convert(input);
    } catch (_) {
      return input.toString();
    }
  }
}


class GQLLogger {
  static final GQLLogger _instance = GQLLogger._internal();
  factory GQLLogger() => _instance;
  GQLLogger._internal();

  final List<Map<String, dynamic>> logs = [];

  void log(String query, Map<String, dynamic> variables, String url, dynamic headers) {
    logs.add({
      'query': query,
      'variables': variables,
      'url': url,
      'headers': headers,
      'response': null,
      'time': DateTime.now(),
    });
  }

  void updateLastResponse(dynamic response) {
    if (logs.isNotEmpty) {
      logs.last['response'] = response;
    }
  }

  List<Map<String, dynamic>> getLogs() => logs.reversed.toList();
}
