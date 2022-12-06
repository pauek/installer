import 'package:console/console.dart';

abstract class Step<T> {
  // Necesito tener los steps aquí???
  final List<Step> _steps;

  Step([List<Step>? steps]) : _steps = steps ?? [];

  List<Step> get steps => _steps;
  int get numInputSteps => 0;

  // Posicionado
  CursorPosition? pos;
  // Este método implica que puedes situar cada step de forma estática...
  // - Lo llamas con una posición y te da la siguiente
  CursorPosition setPos(CursorPosition p) {
    pos = p;
    return CursorPosition(p.column, p.row + 1);
  }

  show(String msg) {
    if (pos == null) {
      throw "Step hasn't been positioned";
    }
    Console.moveCursor(row: pos!.row, column: pos!.column);
    Console.write(msg + " " * (Console.columns - pos!.column - msg.length));
    Console.moveCursor(row: pos!.row, column: pos!.column);
  }

  clear() {
    show("");
  }

  Future<T> run();
}

abstract class SinglePriorStep<T, P> extends Step<T> {
  SinglePriorStep([super.steps]);

  @override
  int get numInputSteps => 1;

  @override
  CursorPosition setPos(CursorPosition p) {
    pos = p;
    return steps[0].setPos(p);
  }

  Future get input {
    if (_steps.isEmpty) {
      throw "Attempted to run null priorStep";
    }
    return _steps[0].run();
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
  CursorPosition setPos(CursorPosition p) {
    pos = p;
    var next = CursorPosition(p.column, p.row);
    for (int i = 0; i < steps.length; i++) {
      next = steps[i].setPos(next);
    }
    return next;
  }
}

class Chain extends Step {
  final String? name;

  Chain({this.name, required List<Step> steps}) : super(steps) {
    if (steps.isEmpty) {
      throw "Chain with no inputs";
    }
    for (int i = 1; i < steps.length; i++) {
      final step = steps[i];
      if (i == 0 && step.numInputSteps != 0) {
        throw "First step in Chain must have 0 inputs";
      }
      if (i > 0 && step.numInputSteps > 1) {
        throw "Second to last steps in Chain must have at most 1 input";
      }
    }

    // Set up chain
    for (int i = 1; i < steps.length; i++) {
      steps[i]._steps.add(steps[i - 1]);
    }
  }

  @override
  Future run() async {
    final prefix = name == null ? "" : "$name: ";
    show(prefix);
    try {
      final result = await steps.last.run();
      if (result != null) {
        show("${prefix}success.");
      }
      return result;
    } catch (e) {
      show("$prefix$e");
    }
    return null;
  }

  int get prefixLen => name == null ? 0 : name!.length + 2;

  @override
  CursorPosition setPos(CursorPosition p) {
    pos = p;
    var next = CursorPosition(p.column, p.row);
    for (int i = 0; i < steps.length; i++) {
      final n = steps[i].setPos(
        CursorPosition(p.column + prefixLen, p.row),
      );
      if (n.row > next.row) {
        next = CursorPosition(p.column, n.row);
      }
    }
    return next;
  }
}
