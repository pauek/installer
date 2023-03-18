import 'package:installer/steps/step.dart';

class Not extends SinglePriorStep {
  Not(Step step) : super("Not ${step.title}", step);

  @override
  Future run() {
    return Future.value(!input);
  }
}
