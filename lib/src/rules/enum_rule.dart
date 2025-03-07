import 'dart:collection';
import 'package:env_guard/env.dart';

abstract interface class Enumerable<T> {
  T get value;
}

final class EnvEnumRule<T> implements EnvRule {
  final String? message;
  final List<Enumerable> source;

  const EnvEnumRule(this.message, this.source);

  @override
  void handle(GuardContext ctx, PropertyContext property) {
    if (property.value == null) {
      return;
    }

    final values = source.where((element) => element.value == property.value);
    if (values.firstOrNull == null) {
      final str = message ?? 'The value must be an enum of ${source.map((e) => e.value).toList()}';
      final error = ctx.errorReporter.format('enum', property, str, {});

      ctx.errorReporter.report('enum', property.name, error);
    }
  }
}
