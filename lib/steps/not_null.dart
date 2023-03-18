import 'package:installer/steps/step.dart';

class NotNull extends SinglePriorStep {
  NotNull(Step step) : super("null != ${step.title}", step);

  @override
  Future run() async {
    return Future.value(input != null);
  }
}
