import 'dart:math';

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

class GiveInteger extends Step<int> {
  int n;
  GiveInteger(this.n);

  @override
  Future<Value<int>> run() async {
    show("Giving integer value... ");
    final r = Random();
    await Future.delayed(Duration(milliseconds: r.nextInt(20) * 100));
    show("Given $n!                      ");
    return Future.value(Value(n));
  }
}

class ShowResult extends SinglePriorStep<void, int> {
  ShowResult(super.priorStep);

  @override
  Future<Value> run() async {
    show("Waiting for result...");
    final x = await input;
    await Future.delayed(Duration(seconds: 1));
    log.print("Value is ${x.value}");
    show("Result is ${x.value}!!           ");
    return Future.value(Value());
  }
}

class ShowManyResults extends MultiPriorStep<List> {
  ShowManyResults(super.priorSteps);

  @override
  Future<Value<List>> run() async {
    show("Waiting for results...");
    final results = await inputs;
    await Future.delayed(Duration(seconds: 1));
    final values = results.map((r) => r.value).toList();
    show("All results = $values");
    return Value(values);
  }
}
