import 'package:env_guard/src/contracts/env.dart';

abstract interface class EnvSchema<T extends ErrorReporter> {
  void parse(GuardContext ctx, PropertyContext field);

  /// Clone the schema
  EnvSchema clone();
}

abstract interface class BasicSchema<T extends EnvSchema> {
  T transform(Function(GuardContext ctx, PropertyContext field) fn);

  T optional();
}

abstract interface class EnvString implements EnvSchema, BasicSchema<EnvString> {}

abstract interface class EnvEnum implements EnvSchema, BasicSchema<EnvEnum> {}

abstract interface class EnvNumber implements EnvSchema, BasicSchema<EnvNumber> {
  /// Check if the number is a double [message] the error message to display
  /// ```dart
  /// vine.number().double();
  /// ```
  /// You can specify a custom error message
  /// ```dart
  /// vine.number().double(message: 'The value must be a double');
  /// ```
  EnvNumber double({String? message});

  /// Check if the number is an integer [message] the error message to display
  /// ```dart
  /// vine.number().integer();
  /// ```
  /// You can specify a custom error message
  /// ```dart
  EnvNumber integer({String? message});
}

abstract interface class EnvBoolean implements EnvSchema, BasicSchema<EnvBoolean> {}
