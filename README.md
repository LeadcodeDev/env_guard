# ⚙️ Env Guard

Env Guard est une bibliothèque de validation robuste et typée pour Dart/Flutter, conçue pour simplifier et sécuriser la gestion des variables d'environnement dans vos applications. la librairie offre une solution élégante pour valider et transformer les données d'environnement, garantissant qu'elles respectent un format attendu avant d'être utilisées.

![icons technologies](https://skillicons.dev/icons?i=dart,flutter)

## 🛠 Key features

| Feature                   | Description                                                |
|---------------------------|------------------------------------------------------------|
| ✅ Type-Safe Validation    | Define schemas with a fluent API and ensure data integrity |
| 🧱 Rich Set of Validators | Strings, numbers, booleans, enums                          |
| 🔄 Data Transformation    | Transform values during validation                         |
| 🚧 Null Safety            | Full support for optional properties                       |
| 📦 Extremely small size   | Package size `< 8kb`                                       |


## ✨ Simply to use

Consider the following example, where we define a schema for our application's environment variables.
```dotenv
HOST=127.0.0.1
PORT=8080
LOG_LEVEL=debug
```

We can validate these environment variables using the `env_guard` library in the following way.
```dart
enum LogLevel implements Enumerate<String>{
  info('info'),
  error('error'),
  debug('debug');
  
  final String value;
  const LogLevel(this.value);
}

void main() {
  env.define({
    'HOST': env.string(),
    'PORT': env.number(),
    'LOG_LEVEL': env.enumerable(LogLevel.values),
  });

  expect(env.get('HOST'), '127.0.0.1');
}
```

### 🚧 Error handling
When your application starts up and your environment does not meet the requirements defined by the validator, an `EnvGuardException` is thrown using the following format.
```json
{
  "errors": [
    {
      "message": "The value must be an enum of [info, error, debug]",
      "rule": "enum",
      "key": "LOG_LEVEL"
    }
  ]
}
```
