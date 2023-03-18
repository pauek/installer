import 'package:installer/steps/step.dart';

typedef StepBuilder = Step Function(Set<String>);

class Option {
  final String name;
  final String description;
  final StepBuilder builder;
  final List<String>? dependencies;

  const Option(this.name, this.builder, this.description, [this.dependencies]);
}
