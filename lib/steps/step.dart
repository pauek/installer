import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:async/async.dart';
import 'package:console/console.dart';
import 'package:installer2/utils.dart';

const brailleFrames = r"⢿⣻⣽⣾⣷⣯⣟⡿";
const frames = r"|/-\";

String getStringAnimation() {
  if (Platform.isWindows) {
    return frames;
  } else {
    return brailleFrames;
  }
}

abstract class Step {
  // Necesito tener los steps aquí???
  Step? _input;

  Step([Step? input]) : _input = input;

  Step get input {
    if (_input == null) {
      return error("Attempting to use _input when null");
    }
    return _input!;
  }

  set input(Step step) {
    _input = step;
  }

  bool get hasInput => _input != null;

  Future waitForInput() async {
    if (hasInput) {
      return await input.run();
    }
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

  homePos() {
    if (pos == null) {
      return error("Step hasn't been positioned");
    }
    Console.moveCursor(row: pos!.row, column: pos!.column);
  }

  show(String msg, {bool clear = true, Color color = Color.WHITE}) {
    homePos();
    final pen = TextPen();
    pen.setColor(color);
    if (clear) {
      pen.text(msg + " " * (Console.columns - pos!.column - msg.length));
    } else {
      pen.text(msg);
    }
    pen.print();
  }

  CancelableOperation hourGlassAnimation() {
    final frames = getStringAnimation();
    bool waiting = true;
    loop() async {
      for (int i = 0; waiting; i = (i + 1) % frames.length) {
        show("${frames[i]} ", clear: false);
        await Future.delayed(Duration(milliseconds: 100));
      }
    }

    return CancelableOperation.fromFuture(
      loop(),
      onCancel: () => waiting = false,
    );
  }

  Future<T> withMessage<T>(String msg, Future Function() func) async {
    final hourGlass = hourGlassAnimation();
    try {
      show("  $msg", color: Color.GRAY);
      final result = await func();
      if (result is InstallerError) {
        show("  $result", color: Color.RED);
      } else {
        show("  $msg", color: Color.GRAY);
      }
      return result;
    } finally {
      hourGlass.cancel();
    }
  }

  Future run();
}

abstract class SinglePriorStep extends Step {
  SinglePriorStep([Step? priorStep]) : super(priorStep);

  @override
  CursorPosition setPos(CursorPosition p) {
    var next = super.setPos(CursorPosition(p.column, p.row));
    if (hasInput) {
      next = input.setPos(p);
    }
    return next;
  }
}

class Parallel extends Step {
  List<Step> parSteps;
  Parallel(this.parSteps);

  @override
  String get description => "Parallel job";

  @override
  Future run() async {
    final result = await waitForInput();
    if (result is InstallerError) {
      return result;
    }
    final results = await Future.wait(
      parSteps.map((s) => s.run()),
    );
    return results;
  }

  @override
  CursorPosition setPos(CursorPosition p) {
    pos = p;
    var next = CursorPosition(p.column, p.row);
    for (final step in parSteps) {
      next = step.setPos(CursorPosition(next.column, next.row));
    }
    return next;
  }
}

abstract class SequenceBase extends Step {
  final List<Step> seqSteps;

  SequenceBase(this.seqSteps) {
    if (seqSteps.isEmpty) {
      error("Chain with no inputs");
    }
    if (seqSteps[0].hasInput) {
      error("First step in Chain shouldn't have input");
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
  Chain.noPrefix(super.seqSteps) : name = "";

  @override
  String get description => name;
  String get prefix => name.isEmpty ? "" : name;

  @override
  int get indent => name.isEmpty ? 0 : max(prefix.length + 1, 14);

  @override
  Future run() async {
    final r1 = await waitForInput();
    if (r1 is InstallerError) {
      return r1;
    }
    show(prefix, color: Color.BLUE);
    final r2 = await seqSteps.last.run();
    if (r2 is InstallerError) {
      Console.moveCursor(row: pos!.row, column: pos!.column + indent);
      final pen = TextPen();
      pen.setColor(Color.RED);
      pen.text("ERROR: ${r2.message}");
      pen.text(
          " " * (Console.columns - pen.buffer.length - pos!.column - indent));
      pen.print();
    } else {
      Console.moveCursor(row: pos!.row, column: pos!.column + indent);
      final pen = TextPen();
      pen.setColor(Color.GREEN);
      pen.text("ok");
      pen.text(
          " " * (Console.columns - pen.buffer.length - pos!.column - indent));
      pen.print();
    }
    return r2;
  }
}

class Sequence extends SequenceBase {
  Sequence(super.seqSteps);

  @override
  int get indent => 0;

  @override
  CursorPosition setPos(CursorPosition p) {
    pos = p;
    var next = CursorPosition(p.column, p.row);
    for (final s in seqSteps) {
      next = s.setPos(next);
    }
    return CursorPosition(next.column, next.row);
  }

  @override
  Future run() async {
    final result = await waitForInput();
    if (result is InstallerError) {
      return result;
    }
    return await seqSteps.last.run();
  }
}
