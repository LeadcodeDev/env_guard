import 'dart:collection';

import 'package:env_guard/env_guard.dart';
import 'package:env_guard/src/rules/basic_rule.dart';

abstract interface class RuleParserContract {
  Queue<EnvRule> get rules;
  void addRule(EnvRule rule, {bool positioned = false});
}

class RuleParser implements RuleParserContract {
  @override
  Queue<EnvRule> rules;

  bool isNullable = false;
  bool isOptional = false;

  RuleParser(this.rules);

  @override
  void addRule(EnvRule rule, {bool positioned = false}) {
    if (positioned) {
      rules.addFirst(rule);
      return;
    }

    rules.add(rule);
  }

  PropertyContext parse(GuardContext ctx, PropertyContext field) {
    if (isOptional) {
      addRule(EnvOptionalRule(), positioned: true);
    }

    while(rules.isNotEmpty) {
      final rule = rules.removeFirst();
      rule.handle(ctx, field);

      if (!field.canBeContinue) break;
      if (ctx.errorReporter.hasErrorForField(field.name)) break;
    }

    return field;
  }
}
