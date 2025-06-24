# graphql_inspector

A Flutter package to intercept and inspect GraphQL API requests and responses — inspired by tools like Chucker for Android and Postman. Ideal for debugging GraphQL requests in development builds.

## 📁 Folder Structure

```
graphql_inspector/
├── lib/
│   └── src/
│       ├── GraphQLLogScreen.dart
│       └── LoggingLink.dart
├── test/
├── README.md
├── pubspec.yaml
├── LICENSE
├── CHANGELOG.md
└── ...
```

## ✨ Features 

- 📦 Logs every GraphQL query, mutation, and variables
- 🎯 Displays request time and response neatly
- 🧾 Pretty JSON viewer with syntax highlighting
- 🔄 Export GraphQL requests as `cURL` commands
- 📋 Copy/share requests directly from your Flutter UI
- 💡 Useful for QA, debugging, and API development

---

## 📸 Screenshots

| Query View | Response View | cURL Export |
|------------|----------------|-------------|
| ![query](screenshots/query.png) | ![response](screenshots/response.png) | ![curl](screenshots/curl.png) |

---

## 🚀 Getting Started

### 1. Add dependency

```yaml
dependencies:
  graphql_inspector: ^1.0.0
```

### 2. Usage

Import the package and wrap your GraphQL client with the `LoggingLink`. You can then use the `GraphQLLogScreen` widget to view logged requests and responses in your app.

```dart
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:graphql_inspector/graphql_inspector.dart';
import 'package:hive_flutter/hive_flutter.dart';

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

- Replace the API URL and headers with your own.
- Use the `GraphQLLogScreen` widget anywhere in your app to inspect requests and responses.