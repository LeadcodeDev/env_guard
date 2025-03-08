import 'dart:io';

import 'package:env_guard/env_guard.dart';
import 'package:test/test.dart';

final class Env implements DefineEnvironment {
  static final String host = 'HOST';
  static final String port = 'PORT';
  static final String uri = 'URI';

  @override
  final Map<String, EnvSchema> schema = {
    host: env.string().optional(),
    port: env.number().integer(),
    uri: env.string(),
  };
}

void main() {
  tearDown(env.dispose);

  test('should load environment from string with one value', () {
    final values = env.parse('FOO=foo');
    expect(values, {'FOO': 'foo'});
  });

  test('should load environment from string with multiple values', () {
    final values = env.parse(['FOO=foo', 'BAR=bar'].join('\n'));
    expect(values, {'FOO': 'foo', 'BAR': 'bar'});
  });

  test('should parse environment variables', () {
    final content = '''
        PORT=8080
        HOST=localhost
      ''';

    final result = env.parse(content);
    expect(result['PORT'], '8080');
    expect(result['HOST'], 'localhost');
  });

  test('should load environment variables from file', () {
    final directory = Directory.systemTemp.createTempSync();
    final file = File('${directory.path}/.env');
    file.writeAsStringSync('''
        PORT=8080
        HOST=localhost
      ''');

    env.define(root: directory, {'PORT': env.number().integer(), 'HOST': env.string()});

    expect(env.get('PORT'), 8080);
    expect(env.get('HOST'), 'localhost');

    directory.deleteSync(recursive: true);
  });

  test('should load environment variables from file', () {
    final directory = Directory.systemTemp.createTempSync();
    final file = File('${directory.path}/.env');
    file.writeAsStringSync('''
        PORT=8080
        HOST=localhost
        URI={HOST}:{PORT}
      ''');

    env.define(root: directory, {
      'PORT': env.number().integer(),
      'HOST': env.string(),
      'URI': env.string(),
    });

    expect(env.get('URI'), 'localhost:8080');
    directory.deleteSync(recursive: true);
  });

  test('should load environment variables with enum declaration', () {
    final directory = Directory.systemTemp.createTempSync();
    final file = File('${directory.path}/.env');
    file.writeAsStringSync('''
        PORT=8080
        HOST=localhost
        URI={HOST}:{PORT}
      ''');

    env.defineOf(Env.new, root: directory);
    expect(env.get(Env.uri), 'localhost:8080');

    directory.deleteSync(recursive: true);
  });

  test('should get null value when environment has not property', () {
    expect(env.get('PORT'), isNull);
  });
}
