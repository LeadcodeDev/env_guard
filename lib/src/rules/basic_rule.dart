import 'package:env_guard/env.dart';

final class EnvOptionalRule implements EnvRule {
  @override
  void handle(GuardContext ctx, PropertyContext field) {
    if (field.value is MissingValue) {
      field.canBeContinue = false;
      ctx.data.remove(field.name);
    }
  }
}

final class EnvTransformRule implements EnvRule {
  final Function(GuardContext, PropertyContext) fn;

  const EnvTransformRule(this.fn);

  @override
  void handle(GuardContext ctx, PropertyContext property) {
    final result = fn(ctx, property);
    property.mutate(result);
  }
}
