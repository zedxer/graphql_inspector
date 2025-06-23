# graphql_inspector

A Flutter package to intercept and inspect GraphQL API requests and responses — inspired by tools like Chucker for Android and Postman. Ideal for debugging GraphQL requests in development builds.

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