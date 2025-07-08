import 'dart:collection';
import 'dart:io';

import 'package:env_guard/env_guard.dart';

final bracketPattern = RegExp(r'\{(\w+)\}');

final class Env {
  ErrorReporter Function() errorReporter = SimpleErrorReporter.new;

  final Map<String, dynamic> _environments = {};
  final _envParser = EnvParser();

  T get<T>(String key, {T? defaultValue}) {
    final currentValue = _environments[key];

    if (currentValue is String) {
      return currentValue.replaceAllMapped(bracketPattern, (match) {
            final variableName = match.group(1);
            return variableName != null
                ? get(variableName)?.toString() ?? ''
                : '';
          })
          as T;
    }

    if (currentValue == null && defaultValue != null) {
      return defaultValue;
    }

    return currentValue as T;
  }

  void dispose() {
    _environments.clear();
  }

  EnvString string({String? message}) {
    final Queue<EnvRule> rules = Queue();
    rules.add(EnvStringRule(message));

    return EnvStringSchema(rules);
  }

  EnvNumber number({String? message}) {
    final Queue<EnvRule> rules = Queue();
    rules.add(EnvNumberRule(message));

    return EnvNumberSchema(rules);
  }

  EnvBoolean boolean({String? message}) {
    final Queue<EnvRule> rules = Queue();
    rules.add(EnvBooleanRule(message));

    return EnvBooleanSchema(rules);
  }

  EnvEnum enumerable<T extends Enumerable>(List<T> source, {String? message}) {
    final Queue<EnvRule> rules = Queue();
    rules.add(EnvEnumRule(message, source));

    return EnvEnumSchema(rules, source);
  }

  Map<String, dynamic> parse(String content) {
    return _envParser.parse(content);
  }

  /// Parses environment variables from a string content into a Map.
  ///
  /// Takes a [content] string containing environment variable definitions in the format:
  /// ```dotenv
  /// KEY1=value1
  /// KEY2=value2
  /// ```
  ///
  /// Returns a [Map<String, dynamic>] where each key is the environment variable name
  /// and the value is the parsed string value.
  ///
  /// Example:
  /// ```dart
  /// final content = '''
  ///   PORT=8080
  ///   HOST=localhost
  /// ''';
  ///
  /// final schema = {
  ///   'PORT': env.number().integer(),
  ///   'HOST': env.string(),
  /// };
  ///
  /// final validatedEnv = env.validate(schema, envVars);
  /// // Returns: {'PORT': 8080, 'HOST': 'localhost'}
  /// ```
  Map<String, dynamic> validate(
    Map<String, EnvSchema> schema,
    Map<String, dynamic> data,
  ) {
    final Map<String, dynamic> resultMap = {};
    final reporter = errorReporter();
    final validatorContext = ValidatorContext(reporter, data);
    final property = Property('', data);

    for (final element in schema.entries) {
      property.name = element.key;
      property.value =
          data.containsKey(element.key) ? data[element.key] : MissingValue();

      element.value.parse(validatorContext, property);
      resultMap[property.name] = property.value;
    }

    if (reporter.hasError) {
      throw reporter.createError({'errors': reporter.errors});
    }

    reporter.clear();

    return resultMap;
  }

  /// Validates environment variables against a schema.
  ///
  /// Takes a [schema] defining the expected structure and validation rules for environment variables,
  /// and [data] containing the actual environment variable values to validate.
  ///
  /// Returns a [Map] containing the validated environment variables. The returned map will have
  /// the same keys as the schema, with values converted and validated according to the schema rules.
  ///
  /// Throws an [EnvGuardException] if any validation errors occur. The exception will contain details
  /// about which validations failed.
  ///
  /// Example:
  /// ```dart
  /// final schema = {
  ///   'PORT': env.number().integer(),
  ///   'HOST': env.string(),
  /// };
  ///
  /// final data = {
  ///   'PORT': '8080',
  ///   'HOST': 'localhost'
  /// };
  ///
  /// final validated = env.validate(schema, data);
  /// // Returns: {'PORT': 8080, 'HOST': 'localhost'}
  /// ```

  void define(
    Map<String, EnvSchema> schema, {
    Directory? root,
    bool includeDartEnv = true,
  }) {
    final loader = Loader(root ?? Directory.current);

    if (includeDartEnv) {
      _environments.addEntries(Platform.environment.entries);
    }

    if (!_environments.containsKey('DART_ENV')) {
      _environments['DART_ENV'] = String.fromEnvironment(
        'DART_ENV',
        defaultValue: 'development',
      );
    }

    final envs = loader.load();
    final target = '.env.${_environments['DART_ENV']}';

    EnvEntry? current =
        envs.where((element) => element.name == target).firstOrNull;
    current ??= envs.where((element) => element.name == '.env').firstOrNull;

    final Map<String, dynamic> validated = {};
    if (current != null) {
      final values = _envParser.parse(current.content);
      for (final element in schema.entries) {
        if (element.key != 'DART_ENV' &&
            _environments.containsKey(element.key)) {
          throw Exception('Environment variable ${element.key} already exists');
        }
      }

      validated.addAll(validate(schema, values));
    } else {
      validated.addAll(validate(schema, _environments));
    }

    for (final element in validated.entries) {
      _environments[element.key] = element.value;
    }
  }

  /// Defines environment variables using a class that implements [DefineEnvironment].
  ///
  /// This method provides a more structured way to define environment variables using a class-based approach.
  /// The class must implement [DefineEnvironment] interface which requires a [schema] property.
  ///
  /// Parameters:
  /// - [source]: A function that returns an instance of type [T] which implements [DefineEnvironment]
  /// - [root]: Optional directory where the .env files are located. Defaults to current directory if not specified
  /// - [includeDartEnv]: Whether to include Dart's environment variables. Defaults to true
  ///
  /// Example:
  /// ```dart
  /// class AppEnv implements DefineEnvironment {
  ///   static final String host = 'HOST';
  ///   static final String port = 'PORT';
  ///
  ///   @override
  ///   final Map<String, EnvSchema> schema = {
  ///     host: env.string(),
  ///     port: env.number().integer(),
  ///   };
  /// }
  ///
  /// env.defineOf(AppEnv.new);
  /// ```
  void defineOf<T extends DefineEnvironment>(
    T Function() source, {
    Directory? root,
    bool includeDartEnv = true,
  }) {
    define(source().schema, root: root, includeDartEnv: includeDartEnv);
  }

  Map<String, dynamic> toJson() => Map.from(_environments);
}

final env = Env();
