import 'package:env_guard/src/contracts/env.dart';

final class Property implements PropertyContext {
  @override
  String name;

  @override
  dynamic value;

  @override
  bool canBeContinue = true;

  Property(this.name, this.value);

  @override
  void mutate(dynamic value) {
    this.value = value;
  }
}
