import 'package:env_guard/src/contracts/env.dart';
import 'package:env_guard/src/contracts/rule.dart';

final class EnvStringRule implements EnvRule {
  final String? message;

  const EnvStringRule(this.message);

  @override
  void handle(GuardContext ctx, PropertyContext field) {
    if (field.value is! String) {
      final error = ctx.errorReporter.format('string', field, message, {});
      ctx.errorReporter.report('string', field.name, error);
    }
  }
}
