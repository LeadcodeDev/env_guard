import 'package:env_guard/env.dart';

final class EnvBooleanRule implements EnvRule {
  final String? message;

  const EnvBooleanRule(this.message);

  @override
  void handle(GuardContext ctx, PropertyContext property) {
    final bool? content = switch (property.value) {
      String() => bool.tryParse(property.value.toString()),
      bool() => property.value,
      _ => null,
    };

    if (content == null) {
      final error = ctx.errorReporter.format('boolean', property, message, {});
      ctx.errorReporter.report('boolean', property.name, error);
    } else {
      property.mutate(content);
    }
  }
}
