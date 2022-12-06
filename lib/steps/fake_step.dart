import 'dart:math';

import 'package:console/console.dart';
import 'package:installer2/steps/step.dart';

class FakeStep extends Step {
  final int number;
  final Duration duration;
  FakeStep(this.number, this.duration);

  @override
  Future run() async {
    if (steps.isNotEmpty) {
      await steps[0].run();
    }
    show("Fake step $number...");

    await Future.delayed(duration);

    clear();
    return true;
  }

  @override
  CursorPosition setPos(CursorPosition p) {
    pos = p;
    return CursorPosition(p.column, p.row + 1);
  }
}

final rnd = Random();

rndDuration() => Duration(milliseconds: rnd.nextInt(1800) + 1200);

final fakeInstaller = Parallel([
  Chain(name: "Chain 1", steps: [
    Parallel([
      FakeStep(1, rndDuration()),
      FakeStep(2, rndDuration()),
      FakeStep(3, rndDuration()),
    ]),
    FakeStep(4, rndDuration()),
  ]),
  Chain(name: "Chain 2", steps: [
    FakeStep(5, rndDuration()),
    FakeStep(6, rndDuration()),
    FakeStep(7, rndDuration()),
  ])
]);
