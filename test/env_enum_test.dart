import 'package:test/test.dart';
import 'package:env_guard/env.dart';

enum MyEnum implements Enumerable<String> {
  first('first'),
  second('second');

  @override
  final String value;

  const MyEnum(this.value);
}

void main() {
  group('EnvEnumSchema and EnvEnumRule', () {
    tearDown(env.dispose);

    test('should parse valid enum value', () {
      final result = env.validate({'foo': env.enumerable(MyEnum.values)}, {'foo': 'first'});
      expect(result['foo'], isNotNull);
      expect(result['foo'], MyEnum.first.value);
    });

    test('should throw error on invalid enum value', () {
      final schema = env.enumerable(MyEnum.values, message: 'Invalid enum value');
      expect(
        () => env.validate({'foo': schema}, {'foo': 'invalid_value'}),
        throwsA(isA<Exception>()),
      );
    });

    test('should throw error on invalid enum type', () {
      expect(
        () => env.validate(
          {'foo': env.enumerable(MyEnum.values, message: 'Invalid enum value')},
          {'foo': 123},
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('should handle optional enum', () {
      expect(
        () => env.validate({'foo': env.enumerable(MyEnum.values).optional()}, {}),
        returnsNormally,
      );
    });

    test('should transform enum value', () {
      final schema = env.enumerable(MyEnum.values).transform((ctx, property) => MyEnum.second);
      final result = env.validate({'foo': schema}, {'foo': 'second'});

      expect(result['foo'], MyEnum.second);
    });

    test('should transform enum value to enumerate instance', () {
      final schema = env
          .enumerable(MyEnum.values)
          .transform(
            (ctx, property) =>
                MyEnum.values.firstWhere((element) => element.value == property.value),
          );
      final result = env.validate({'foo': schema}, {'foo': 'second'});

      expect(result['foo'], MyEnum.second);
    });

    test('should clone enum schema', () {
      final schema = env.enumerable(MyEnum.values);
      final clonedSchema = schema.clone();
      expect(clonedSchema, isA<EnvEnumSchema>());
      expect(clonedSchema, isNot(same(schema)));
    });
  });
}
