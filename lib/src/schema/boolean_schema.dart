import 'dart:collection';

import 'package:env_guard/src/contracts/env.dart';
import 'package:env_guard/src/contracts/schema.dart';
import 'package:env_guard/src/rule_parser.dart';
import 'package:env_guard/src/rules/basic_rule.dart';

final class EnvBooleanSchema extends RuleParser implements EnvBoolean {
  EnvBooleanSchema(super._rules);

  @override
  EnvBoolean transform(Function(GuardContext, PropertyContext) fn) {
    super.addRule(EnvTransformRule(fn));
    return this;
  }

  @override
  EnvBoolean optional() {
    super.isOptional = true;
    return this;
  }

  @override
  EnvBoolean clone() {
    return EnvBooleanSchema(Queue.of(rules));
  }
}
