import 'package:env_guard/env.dart';
import 'package:env_guard/src/exceptions/validation_exception.dart';

class SimpleErrorReporter implements ErrorReporter {
  @override
  final List<Map<String, Object>> errors = [];

  @override
  bool hasError = false;

  @override
  bool hasErrorForField(String fieldName) => errors.any((element) => element['field'] == fieldName);

  @override
  String format(String rule, PropertyContext field, String? message, Map<String, dynamic> options) {
    String content = message ?? '';
    for (final element in options.entries) {
      content = content.replaceAll('{${element.key}}', element.value.toString());
    }

    return content
        .replaceAll('{name}', field.name)
        .replaceAll('{value}', field.value.toString());
  }

  @override
  void report(String rule, String name, String message) {
    hasError = true;
    errors.add({'message': message, 'rule': rule, 'key': name});
  }

  @override
  Exception createError(Object message) {
    return EnvGuardException(message.toString());
  }

  @override
  void clear() {
    if (hasError) {
      errors.clear();
      hasError = false;
    }
  }
}
