import 'dart:io';
import 'dart:collection';

import 'package:env_guard/src/contracts/env.dart';
import 'package:env_guard/src/contracts/rule.dart';
import 'package:env_guard/src/contracts/schema.dart';
import 'package:env_guard/src/env_parser.dart';
import 'package:env_guard/src/loader.dart';
import 'package:env_guard/src/property.dart';
import 'package:env_guard/src/rules/number_rule.dart';
import 'package:env_guard/src/rules/string_rule.dart';
import 'package:env_guard/src/schema/number_schema.dart';
import 'package:env_guard/src/schema/string_schema.dart';
import 'package:env_guard/src/simple_error_reporter.dart';
import 'package:env_guard/src/validator.dart';

final class Env {
  ErrorReporter Function() errorReporter = SimpleErrorReporter.new;

  final Map<String, dynamic> _environments = {};
  final parser = EnvParser();

  T get<T>(String key) {
    return _environments[key] as T;
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
      property.value = data[element.key];

      element.value.parse(validatorContext, property);
      resultMap[property.name] = property.value;
    }

    if (reporter.hasError) {
      throw reporter.createError({'errors': reporter.errors});
    }

    reporter.clear();

    return resultMap;
  }

  Map<String, dynamic> create(
    Map<String, EnvSchema> schema, {
    Directory? root,
    bool includeDartEnv = false,
  }) {
    final loader = Loader(root ?? Directory.current);

    if (includeDartEnv) {
      _environments.addEntries(Platform.environment.entries);
    }

    _environments['DART_ENV'] = String.fromEnvironment('DART_ENV', defaultValue: 'development');

    final envs = loader.load();

    final target = '.env.${_environments['DART_ENV']}';
    EnvEntry? current = envs.where((element) => element.name == target).firstOrNull;

    current ??= envs.firstWhere(
      (element) => element.name == '.env',
      orElse: () => throw Exception('Environment file not found'),
    );

    final values = parser.parse(current.content);
    for (final element in values.entries) {
      if (_environments.containsKey(element.key)) {
        throw Exception('Environment variable ${element.key} already exists');
      }

      _environments[element.key] = element.value;
    }

    final validated = validate(schema, _environments);

    _environments
      ..clear()
      ..addAll(validated);

    return _environments;
  }
}

final env = Env();
