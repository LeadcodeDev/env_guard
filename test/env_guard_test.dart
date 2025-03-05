import 'dart:io';

import 'package:env_guard/env.dart';
import 'package:env_guard/src/exceptions/validation_exception.dart';
import 'package:test/test.dart';

enum Env {
  secret('SECRET'),
  secret2('SECRET_2');

  final String value;

  const Env(this.value);
}

void main() {
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

  test('should validate environment variables', () {
    final schema = {
      'PORT': env.number().integer(),
      'HOST': env.string(),
    };
    final data = {
      'PORT': '8080',
      'HOST': 'localhost',
    };
    final result = env.validate(schema, data);
    expect(result['PORT'], 8080);
    expect(result['HOST'], 'localhost');
  });

  test('should throw error on invalid environment variables', () {
    final schema = {
      'PORT': env.number().integer(),
      'HOST': env.string(),
    };
    final data = {
      'PORT': 'not a number',
      'HOST': 'localhost',
    };
    expect(() => env.validate(schema, data), throwsA(isA<EnvGuardException>()));
  });

  test('should load environment variables from file', () {
    final directory = Directory.systemTemp.createTempSync();
    final file = File('${directory.path}/.env');
    file.writeAsStringSync('''
        PORT=8080
        HOST=localhost
      ''');

    final schema = {
      'PORT': env.number().integer(),
      'HOST': env.string(),
    };

    final result = env.create(schema, root: directory);
    expect(result['PORT'], 8080);
    expect(result['HOST'], 'localhost');

    directory.deleteSync(recursive: true);
  });
}
