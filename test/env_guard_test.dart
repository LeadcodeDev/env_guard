import 'dart:io';

import 'package:env_guard/env.dart';
import 'package:env_guard/src/exceptions/validation_exception.dart';
import 'package:test/test.dart';

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

    env.define(root: directory, {
      'PORT': env.number().integer(),
      'HOST': env.string(),
    });

    expect(env.get('PORT'), 8080);
    expect(env.get('HOST'), 'localhost');

    directory.deleteSync(recursive: true);
  });

  test('should delete environment key from delete method', () {
    expect(env.get('PORT'), isNull);
  });
}
