import 'package:env_guard/env.dart';

final class EnvStringRule implements EnvRule {
  final String? message;

  const EnvStringRule(this.message);

  @override
  void handle(GuardContext ctx, PropertyContext field) {
    if (field.value is! String) {
      final str = message ?? 'The value must be a string';
      final error = ctx.errorReporter.format('string', field, str, {});
      ctx.errorReporter.report('string', field.name, error);
    }
  }
}
