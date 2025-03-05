import 'package:env_guard/src/contracts/env.dart';

abstract interface class EnvRule {
  void handle(GuardContext ctx, PropertyContext property);
}
