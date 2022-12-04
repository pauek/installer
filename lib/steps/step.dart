import 'package:console/console.dart';

abstract class Step<T> {
  List<Step> _steps;
  CursorPosition? _pos;
  Step([List<Step>? steps]) : _steps = steps ?? [];

  int get numInputSteps => 0;
  List<Step> get steps => _steps;

  set pos(CursorPosition p) => _pos = p;

  show(String msg) {
    if (_pos == null) {
      throw "Step hasn't been positioned";
    }
    Console.moveCursor(row: _pos!.row, column: _pos!.column);
    Console.write(msg);
  }

  Future<T> run();
}

abstract class SinglePriorStep<T, P> extends Step<T> {
  SinglePriorStep();

  @override
  int get numInputSteps => 1;

  Future get input {
    if (_steps.isEmpty) {
      throw "Attempted to run null priorStep";
    }
    return _steps[0].run();
  }

  @override
  set pos(CursorPosition p) {
    super.pos = p;
    if (_steps.isEmpty) {
      throw "Attempted to set position of a null priorStep";
    }
    _steps[0].pos = CursorPosition(p.column + 2, p.row + 1);
  }
}

class Parallel extends Step {
  Parallel(List<Step> steps) : super(steps);

  Future<List> get inputs {
    return Future.wait(
      steps.map((step) => step.run()),
    );
  }

  @override
  Future<List> run() async => await inputs;

  @override
  set pos(CursorPosition p) {
    super.pos = p;
    int row = p.row + 1;
    for (int i = 0; i < steps.length; i++) {
      steps[i].pos = CursorPosition(p.column + 2, row);
      row += 1 + steps[i].numInputSteps;
    }
  }
}

class Chain<T, P> extends Step<T> {
  Chain(List<Step> inputSteps) : super(inputSteps) {
    if (steps.isEmpty) {
      throw "Chain with no inputs";
    }
    for (int i = 1; i < steps.length; i++) {
      final step = steps[i];
      if (i == 0 && step.numInputSteps != 0) {
        throw "First step in Chain must have 0 inputs";
      }
      if (i > 0 && step.numInputSteps != 1) {
        throw "Second to last steps in Chain must have 1 input";
      }
    }

    // Set up chain
    for (int i = 1; i < steps.length; i++) {
      steps[i]._steps.add(steps[i - 1]);
    }
  }

  @override
  Future<T> run() async => await steps.last.run();

  @override
  set pos(CursorPosition p) {
    super.pos = p;
    for (int i = 0; i < steps.length; i++) {
      steps[i].pos = p;
    }
  }
}
