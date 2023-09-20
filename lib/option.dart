import 'package:installer/steps/step.dart';

typedef StepBuilder = Step Function();

class Option {
  final String name;
  final String description;
  final StepBuilder builder;
  final List<String>? dependencies;
  int order = 0;

  Option(this.name, this.builder, this.description, this.order, [this.dependencies]);
}
