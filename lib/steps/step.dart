import 'package:console/console.dart';
import 'package:installer2/log.dart';

abstract class Step<T> {
  // Necesito tener los steps aquí???
  Step? _input;

  Step([Step? input]) : _input = input;

  Step get input {
    if (_input == null) {
      throw "Attempting to use _input when null";
    }
    return _input!;
  }

  set input(Step step) {
    _input = step;
  }

  bool get hasInput => _input != null;

  Future waitForInput() async {
    return (_input != null ? await input.run() : null);
  }

  // Descripción
  String get description => throw UnimplementedError();

  // Posicionado
  CursorPosition? pos;
  // Este método implica que puedes situar cada step de forma estática...
  // - Lo llamas con una posición y te da la siguiente
  CursorPosition setPos(CursorPosition p) {
    pos = CursorPosition(p.column, p.row);
    return CursorPosition(p.column, p.row + 1);
  }

  show(String msg) {
    if (pos == null) {
      throw "Step hasn't been positioned";
    }
    Console.moveCursor(row: pos!.row, column: pos!.column);
    Console.write(msg + " " * (Console.columns - pos!.column - msg.length));
  }

  Future<T> run();
}

abstract class SinglePriorStep<T, P> extends Step<T> {
  SinglePriorStep([Step? priorStep]) : super(priorStep);

  @override
  CursorPosition setPos(CursorPosition p) {
    pos = CursorPosition(p.column, p.row);
    return input.setPos(p);
  }
}

class Parallel extends Step {
  List<Step> parSteps;
  Parallel(this.parSteps);

  @override
  String get description => "Parallel job";

  @override
  Future<List> run() async {
    await waitForInput();
    return Future.wait(
      parSteps.map((s) => s.run()),
    );
  }

  @override
  CursorPosition setPos(CursorPosition p) {
    pos = p;
    var next = CursorPosition(p.column, p.row);
    for (int i = 0; i < parSteps.length; i++) {
      next = parSteps[i].setPos(CursorPosition(next.column, next.row));
    }
    return next;
  }
}

abstract class SequenceBase extends Step {
  final List<Step> seqSteps;

  SequenceBase(this.seqSteps) {
    if (seqSteps.isEmpty) {
      throw "Chain with no inputs";
    }
    if (seqSteps[0].hasInput) {
      throw "First step in Chain shouldn't have input";
    }

    // Set up chain
    for (int i = 1; i < seqSteps.length; i++) {
      seqSteps[i].input = seqSteps[i - 1];
    }
  }

  int get indent;

  @override
  CursorPosition setPos(CursorPosition p) {
    for (final step in seqSteps) {
      step.setPos(CursorPosition(p.column + indent, p.row));
    }
    return super.setPos(p);
  }
}

class Chain extends SequenceBase {
  final String name;
  Chain(this.name, super.seqSteps);

  @override
  String get description => name;
  String get prefix => "$name:";

  @override
  int get indent => prefix.length;

  @override
  Future run() async {
    await waitForInput();
    show(prefix);
    try {
      final result = await seqSteps.last.run();
      if (result != null) {
        show("$prefix ✓");
      }
      return result;
    } catch (e) {
      show("$prefix ⨉ $e");
      log.print("Error: $e");
      return null;
    }
  }
}

class Sequence extends SequenceBase {
  Sequence(super.seqSteps);

  @override
  int get indent => 0;

  @override
  CursorPosition setPos(CursorPosition p) {
    pos = p;
    var next = p;
    for (final s in seqSteps) {
      next = s.setPos(next);
    }
    return next;
  }

  @override
  Future run() async {
    await waitForInput();
    try {
      await seqSteps.last.run();
      return true;
    } catch (e) {
      log.print("Error: $e");
      return null;
    }
  }
}
