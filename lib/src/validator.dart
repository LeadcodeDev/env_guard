import 'package:env_guard/env.dart';

final class ValidatorContext<T extends ErrorReporter> implements GuardContext<T> {
  @override
  final T errorReporter;

  @override
  final Map<String, dynamic> data;

  ValidatorContext(this.errorReporter, this.data);
}

final class Validator implements ValidatorContract {
  final EnvSchema _schema;
  final Map<String, String> errors;
  final reporter = env.errorReporter();

  Validator(this._schema, this.errors);

  Map<String, dynamic> validate(Map<String, dynamic> data) {
    final validatorContext = ValidatorContext(reporter, data);
    final field = Property('', data);
    _schema.parse(validatorContext, field);

    if (reporter.hasError) {
      throw reporter.createError({'errors': reporter.errors});
    }

    reporter.clear();
    return field.value;
  }
}
