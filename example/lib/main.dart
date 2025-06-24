import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:graphql_inspector/graphql_inspector.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  final httpLink = HttpLink(
    'https://your.graphql.api/graphql',
    defaultHeaders: {'Authorization': 'Bearer YOUR_TOKEN', 'store': 'en_sa'},
  );

  final loggingLink = LoggingLink(
    innerLink: httpLink,
    url: 'https://your.graphql.api/graphql',
    headers: {'Authorization': 'Bearer YOUR_TOKEN', 'store': 'en_sa'},
  );

  final client = GraphQLClient(link: loggingLink, cache: GraphQLCache());

  runApp(MyApp(client: client));
}

class MyApp extends StatelessWidget {
  final GraphQLClient client;
  const MyApp({super.key, required this.client});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('GraphQL Inspector Example')),
        body: Center(
          child: Builder(
            builder: (context) => ElevatedButton(
              child: const Text('Open Inspector'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const GraphQLLogScreen()),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
