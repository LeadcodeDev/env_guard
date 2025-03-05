import 'dart:collection';

import 'package:env_guard/src/contracts/env.dart';
import 'package:env_guard/src/contracts/schema.dart';
import 'package:env_guard/src/rule_parser.dart';
import 'package:env_guard/src/rules/basic_rule.dart';
import 'package:env_guard/src/rules/number_rule.dart';

final class EnvNumberSchema extends RuleParser implements EnvNumber {
  EnvNumberSchema(super._rules);

  @override
  EnvNumber double({String? message}) {
    super.addRule(EnvDoubleRule(message));
    return this;
  }

  @override
  EnvNumber integer({String? message}) {
    super.addRule(EnvIntegerRule(message));
    return this;
  }

  @override
  EnvNumber transform(Function(GuardContext, PropertyContext) fn) {
    super.addRule(EnvTransformRule(fn));
    return this;
  }

  @override
  EnvNumber optional() {
    super.isOptional = true;
    return this;
  }

  @override
  EnvNumber clone() {
    return EnvNumberSchema(Queue.of(rules));
  }
}
