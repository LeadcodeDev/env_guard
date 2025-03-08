# ⚙️ Env Guard

Env Guard is a robust, typed validation library for Dart/Flutter, designed to simplify and secure the management of environment variables in your applications. 

The library offers an elegant solution for validating and transforming environment data, ensuring that it complies with an expected format before being used.

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
URI={HOST}:{PORT}
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
  expect(env.get('URI'), '127.0.0.1:8080');
}
```

### 💪 Enforce data recovery

You can define your validation constraints from an enumeration to make the names of your variables contractual in addition to your types.

```dart
final class Env implements DefineEnvironment {
  static final String host = 'HOST';
  static final String port = 'PORT';
  static final String uri = 'URI';

  @override
  final Map<String, EnvSchema> constraints = {
    host: env.string().optional(),
    port: env.number().integer(),
    uri: env.string(),
  };
}
```

```dart
void main() {
  env.defineOf(Env.new);

  expect(env.get(Env.host), '127.0.0.1');
  expect(env.get(Env.port), 8080);
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
