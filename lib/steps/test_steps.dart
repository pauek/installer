import 'package:installer2/log.dart';
import 'package:installer2/steps/step.dart';
import 'package:installer2/steps/types.dart';

class LogSomething extends Step {
  @override
  Future<Value> run() {
    log.print("Something");
    return Future.value(Value());
  }
}

class GiveFive extends Step<int> {
  @override
  Future<Value<int>> run() {
    return Future.value(Value(5));
  }
}

class ShowResult extends SinglePriorStep<void, int> {
  ShowResult(super.priorStep);

  @override
  Future<Value> run() async {
    final x = await input;
    log.print("Value is ${x.value}");
    print("Value is ${x.value}");
    return Future.value(Value());
  }
}
