import 'dart:collection';

import 'package:env_guard/src/contracts/env.dart';
import 'package:env_guard/src/contracts/schema.dart';
import 'package:env_guard/src/rule_parser.dart';
import 'package:env_guard/src/rules/basic_rule.dart';

final class EnvStringSchema extends RuleParser implements EnvString {
  EnvStringSchema(super._rules);

  @override
  EnvString transform(Function(GuardContext, PropertyContext) fn) {
    super.addRule(EnvTransformRule(fn));
    return this;
  }

  @override
  EnvString optional() {
    super.isOptional = true;
    return this;
  }

  @override
  EnvSchema<ErrorReporter> clone() {
    return EnvStringSchema(Queue.of(rules));
  }
}
