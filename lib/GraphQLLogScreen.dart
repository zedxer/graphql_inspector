import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'LoggingLink.dart';

class GraphQLLogScreen extends StatelessWidget {
  const GraphQLLogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final logs = GQLLogger().getLogs();


    return Scaffold(
      appBar: AppBar(
        title: const Text('GraphQL Inspector'),
      ),
      body: logs.isEmpty
          ? const Center(child: Text("No logs available"))
          : ListView.builder(
        itemCount: logs.length,
        itemBuilder: (context, index) {
          final log = logs[index];
          final url = log['url'];
          final headers = log['headers'];
          return Card(
            margin: const EdgeInsets.all(8),
            child: ExpansionTile(
              title: Text(_extractOperationName(log['query']) ?? 'GraphQL Query'),
              subtitle: Text(log['time'].toString()),
              children: [
                _buildSectionForQuery("🌎 URL", (log['url'])),
                _buildSectionForQuery("🔹 Query", log['query']),
                _buildSectionForQuery("🔺 Headers", _prettyJson(log['headers'])),
                _buildSection("🔸 Variables", _prettyJson(log['variables'])),
                _buildSection("🟢 Response", log['response']),
                ButtonBar(
                  alignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      icon: const Icon(Icons.share),
                      label: const Text("Share cURL"),
                      onPressed: () {
                        final curl = _buildCurlCommand(url, headers, log);
                        _shareCurlCommand(context, curl);
                      },
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
  String? _extractOperationName(String? query) {
    if (query == null) return null;
    final match = RegExp(r'(query|mutation)\s+(\w+)').firstMatch(query);
    return match != null ? match.group(2) : null;
  }
  String _prettyJson(dynamic input) {
    try {
      return const JsonEncoder.withIndent('  ').convert(input);
    } catch (_) {
      return input.toString();
    }
  }
  Widget _buildSectionForQuery(String title, dynamic content) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Text(
              content?.toString() ?? "N/A",
              style: const TextStyle(fontFamily: 'Courier', fontSize: 12),
            ),
          )
        ],
      ),
    );
  }
  Widget _buildSection(String title, dynamic content) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SelectableText.rich(
                _colorizeJson((content)),
                style: const TextStyle(fontFamily: 'Courier', fontSize: 12),
              ),
            ),
          )
        ],
      ),
    );
  }

  TextSpan _colorizeJson(String input) {
    final regex = RegExp(
      r'("(\\u[a-zA-Z0-9]{4}|\\[^u]|[^\\"])*"(\s*:)?|[0-9.+-eE]+|true|false|null)',
      multiLine: true,
    );

    final spans = <TextSpan>[];
    int lastMatchEnd = 0;

    for (final match in regex.allMatches(input)) {
      if (match.start > lastMatchEnd) {
        spans.add(TextSpan(text: input.substring(lastMatchEnd, match.start)));
      }

      final matchText = match.group(0)!;
      TextStyle style;

      if (matchText.startsWith('"')) {
        if (matchText.endsWith(':')) {
          style = const TextStyle(color: Colors.purple); // Keys
        } else {
          style = const TextStyle(color: Colors.teal); // String values
        }
      } else if (matchText == 'true' || matchText == 'false') {
        style = const TextStyle(color: Colors.orange); //booleans
      } else if (matchText == 'null') {
        style = const TextStyle(color: Colors.grey); // null
      } else {
        style = const TextStyle(color: Colors.blue); // Numbers
      }

      spans.add(TextSpan(text: matchText, style: style));
      lastMatchEnd = match.end;
    }

    if (lastMatchEnd < input.length) {
      spans.add(TextSpan(text: input.substring(lastMatchEnd)));
    }

    return TextSpan(children: spans);
  }

  String _buildCurlCommand(String url, dynamic headers, Map<String, dynamic> log) {


    final payload = {
      'query': log['query'],
      'variables': log['variables'],
    };

    final headerString = headers.entries
        .map((e) => "-H '${e.key}: ${e.value}'")
        .join(' ');

    final dataString = jsonEncode(payload).replaceAll("'", r"'\''");

    return "curl -X POST $headerString -d '$dataString' '$url'";
  }

  void _shareCurlCommand(BuildContext context, String curl) {
    Clipboard.setData(ClipboardData(text: curl));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('cURL copied to clipboard')),
    );
  }
}
