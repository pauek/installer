import 'package:installer2/steps/types.dart';

abstract class Step<T> {
  Future<Value<T>> run();
}

abstract class SinglePriorStep<T, P> extends Step<T> {
  Step<P> priorStep;
  SinglePriorStep(this.priorStep);

  Future<Value<P>> get input => priorStep.run();
}

abstract class MultiPriorStep<T> extends Step<T> {
  List<Step> priorSteps;
  MultiPriorStep(this.priorSteps);

  Future<List<Value>> get inputs {
    return Future.wait(
      priorSteps.map((step) => step.run()),
    );
  }
}
