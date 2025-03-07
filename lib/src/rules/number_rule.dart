import 'package:env_guard/env.dart';

void handleNumberConversionError (GuardContext ctx, PropertyContext property, String? message) {
  final str = message ?? 'The value must be a number';
  final error = ctx.errorReporter.format('number', property, str, {});
  ctx.errorReporter.report('number', property.name, error);
}

final class EnvNumberRule implements EnvRule {
  final String? message;
  const EnvNumberRule(this.message);

  @override
  void handle(GuardContext ctx, PropertyContext property) {
    final value = property.value;

    if (value is num) return;
    if (value is! String) {
      handleNumberConversionError(ctx, property, message);
      return;
    }

    final parsed = num.tryParse(value);
    if (parsed == null) {
      handleNumberConversionError(ctx, property, message);
      return;
    }

    property.mutate(parsed);
  }
}

final class EnvDoubleRule implements EnvRule {
  final String? message;

  const EnvDoubleRule(this.message);

  @override
  void handle(GuardContext ctx, PropertyContext property) {
    if (property.value case num value when value is! double) {
      final error = ctx.errorReporter.format('double', property, message, {});
      ctx.errorReporter.report('double', property.name, error);
    }
  }
}

final class EnvIntegerRule implements EnvRule {
  final String? message;

  const EnvIntegerRule(this.message);

  @override
  void handle(GuardContext ctx, PropertyContext property) {
    if (property.value case num value when value is! int) {
      final error = ctx.errorReporter.format('integer', property, message, {});
      ctx.errorReporter.report('integer', property.name, error);
    }
  }
}
