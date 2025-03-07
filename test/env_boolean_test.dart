import 'package:test/test.dart';
import 'package:env_guard/env_guard.dart';

void main() {
  group('EnvBooleanSchema and EnvBooleanRule', () {
    tearDown(env.dispose);

    test('should parse valid boolean string "true"', () {
      final result = env.validate({'test': env.boolean()}, {'test': 'true'});
      expect(result['test'], isTrue);
    });

    test('should parse valid boolean string "false"', () {
      final result = env.validate({'test': env.boolean()}, {'test': 'false'});
      expect(result['test'], isFalse);
    });

    test('should parse valid boolean true', () {
      final result = env.validate({'test': env.boolean()}, {'test': true});
      expect(result['test'], isTrue);
    });

    test('should parse valid boolean false', () {
      final result = env.validate({'test': env.boolean()}, {'test': false});
      expect(result['test'], isFalse);
    });

    test('should throw error on invalid boolean string', () {
      final schema = env.boolean(message: 'Invalid boolean value');
      expect(
        () => env.validate({'test': schema}, {'test': 'not_a_boolean'}),
        throwsA(isA<Exception>()),
      );
    });

    test('should throw error on invalid boolean type', () {
      expect(
        () => env.validate({'test': env.boolean(message: 'Invalid boolean value')}, {'test': 123}),
        throwsA(isA<Exception>()),
      );
    });

    test('should handle optional boolean', () {
      expect(() => env.validate({'test': env.boolean().optional()}, {}), returnsNormally);
    });

    test('should transform boolean value', () {
      final schema = env.boolean().transform((ctx, property) => false);
      final result = env.validate({'test': schema}, {'test': true});

      expect(result['test'], isFalse);
    });

    test('should clone boolean schema', () {
      final schema = env.boolean();
      final clonedSchema = schema.clone();
      expect(clonedSchema, isA<EnvBooleanSchema>());
      expect(clonedSchema, isNot(same(schema)));
    });
  });
}
