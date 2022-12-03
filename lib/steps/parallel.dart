import 'package:installer2/steps/step.dart';

class Parallel extends MultiPriorStep {
  Parallel(super.priorSteps);

  @override
  Future run() async {
    await inputs;
  }
}
