abstract interface class ErrorReporter {
  List<Map<String, Object>> get errors;

  abstract bool hasError;

  bool hasErrorForField(String propertyName);

  String format(String rule, PropertyContext field, String? message, Map<String, dynamic> options);

  void report(String rule, String propertyName, String message);

  Exception createError(Object message);

  void clear();
}

abstract interface class GuardContext<T extends ErrorReporter> {
  T get errorReporter;
  Map get data;
}

abstract interface class PropertyContext {
  abstract String name;
  abstract bool canBeContinue;

  dynamic value;

  void mutate(dynamic value);
}

final class MissingValue {}

abstract interface class ValidatorContract {}
