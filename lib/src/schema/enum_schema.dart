import 'dart:collection';

import 'package:env_guard/env_guard.dart';
import 'package:env_guard/src/rule_parser.dart';
import 'package:env_guard/src/rules/basic_rule.dart';

final class EnvEnumSchema<T extends Enumerable> extends RuleParser implements EnvEnum {
  final List<T> _source;
  EnvEnumSchema(super._rules, this._source);

  @override
  EnvEnum transform(Function(GuardContext, PropertyContext) fn) {
    super.addRule(EnvTransformRule(fn));
    return this;
  }

  @override
  EnvEnum optional() {
    super.isOptional = true;
    return this;
  }

  @override
  EnvEnum clone() {
    return EnvEnumSchema(Queue.of(rules), _source.toList());
  }
}
