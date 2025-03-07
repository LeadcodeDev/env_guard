import 'dart:io';
import 'dart:collection';

import 'package:env_guard/env_guard.dart';

final class Env {
  ErrorReporter Function() errorReporter = SimpleErrorReporter.new;

  final Map<String, dynamic> _environments = {};
  final parser = EnvParser();

  T get<T>(String key) {
    return _environments[key] as T;
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
    return parser.parse(content);
  }

  Map<String, dynamic> validate(Map<String, EnvSchema> schema, Map<String, dynamic> data) {
    final Map<String, dynamic> resultMap = {};
    final reporter = errorReporter();
    final validatorContext = ValidatorContext(reporter, data);
    final property = Property('', data);

    for (final element in schema.entries) {
      property.name = element.key;
      property.value = data.containsKey(element.key) ? data[element.key] : MissingValue();

      element.value.parse(validatorContext, property);
      resultMap[property.name] = property.value;
    }

    if (reporter.hasError) {
      throw reporter.createError({'errors': reporter.errors});
    }

    reporter.clear();

    return resultMap;
  }

  void define(Map<String, EnvSchema> schema, {Directory? root, bool includeDartEnv = true}) {
    final loader = Loader(root ?? Directory.current);

    if (includeDartEnv) {
      _environments.addEntries(Platform.environment.entries);
    }

    if (!_environments.containsKey('DART_ENV')) {
      _environments['DART_ENV'] = String.fromEnvironment('DART_ENV', defaultValue: 'development');
    }

    final envs = loader.load();
    final target = '.env.${_environments['DART_ENV']}';

    EnvEntry? current = envs.where((element) => element.name == target).firstOrNull;
    current ??= envs.where((element) => element.name == '.env').firstOrNull;

    final Map<String, dynamic> validated = {};
    if (current != null) {
      final values = parser.parse(current.content);
      for (final element in values.entries) {
        if (_environments.containsKey(element.key)) {
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
}

final env = Env();
