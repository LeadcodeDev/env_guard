import 'package:test/test.dart';
import 'package:env_guard/env.dart';

void main() {
  group('EnvBooleanSchema and EnvBooleanRule', () {
    tearDown(env.dispose);

    test('should parse valid string string "true"', () {
      final result = env.validate({'foo': env.string()}, {'foo': 'foo'});
      expect(result['foo'], isNotNull);
      expect(result['foo'], 'foo');
    });

    test('should throw error on invalid string', () {
      final schema = env.string(message: 'Invalid string value');
      expect(() => env.validate({'foo': schema}, {'foo': 1}), throwsA(isA<Exception>()));
    });

    test('should throw error on invalid string type', () {
      expect(
        () => env.validate({'foo': env.string(message: 'Invalid string value')}, {'foo': 123}),
        throwsA(isA<Exception>()),
      );
    });

    test('should handle optional string', () {
      expect(() => env.validate({'foo': env.string().optional()}, {}), returnsNormally);
    });

    test('should transform string value', () {
      final schema = env.string().transform((ctx, property) => 'bar');
      final result = env.validate({'foo': schema}, {'foo': 'foo'});

      expect(result['foo'], 'bar');
    });

    test('should clone string schema', () {
      final schema = env.string();
      final clonedSchema = schema.clone();
      expect(clonedSchema, isA<EnvStringSchema>());
      expect(clonedSchema, isNot(same(schema)));
    });
  });
}
