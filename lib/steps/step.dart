import 'package:console/console.dart';
import 'package:installer2/steps/types.dart';

abstract class Step<T> {
  Future<Value<T>> run();
  late CursorPosition _pos;

  int get numPriorSteps => 0;

  set pos(CursorPosition p) {
    _pos = p;
  }

  show(String msg) {
    Console.moveCursor(row: _pos.row, column: _pos.column);
    Console.write(msg);
  }
}

abstract class SinglePriorStep<T, P> extends Step<T> {
  Step<P> priorStep;
  SinglePriorStep(this.priorStep);

  @override
  int get numPriorSteps => 1;

  Future<Value<P>> get input => priorStep.run();

  @override
  set pos(CursorPosition p) {
    super.pos = p;
    priorStep.pos = CursorPosition(p.column + 2, p.row + 1);
  }
}

abstract class MultiPriorStep<T> extends Step<T> {
  List<Step> priorSteps;
  MultiPriorStep(this.priorSteps);

  @override
  int get numPriorSteps => priorSteps.length;

  Future<List<Value>> get inputs {
    return Future.wait(
      priorSteps.map((step) => step.run()),
    );
  }

  @override
  set pos(CursorPosition p) {
    super.pos = p;
    int row = p.row + 1;
    for (int i = 0; i < priorSteps.length; i++) {
      priorSteps[i].pos = CursorPosition(p.column + 2, row);
      row += 1 + priorSteps[i].numPriorSteps;
    }
  }
}
