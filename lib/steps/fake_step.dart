import 'dart:math';

import 'package:console/console.dart';
import 'package:installer2/steps/step.dart';

class FakeStep extends Step {
  final int number;
  final Duration duration;
  FakeStep(this.number, this.duration);

  @override
  Future run() async {
    await waitForInput();
    return await withMessage("Fake step $number", () async {
      await Future.delayed(duration);
      return true;
    });
  }

  @override
  CursorPosition setPos(CursorPosition p) {
    pos = p;
    return CursorPosition(p.column, p.row + 1);
  }
}

final rnd = Random();

rndDuration() => Duration(milliseconds: rnd.nextInt(900) + 600);

final fakeInstaller = Sequence([
  Parallel([
    Chain("Chain 1", [
      FakeStep(1, rndDuration()),
      FakeStep(2, rndDuration()),
      FakeStep(3, rndDuration()),
      FakeStep(4, rndDuration()),
    ]),
    Chain("Chain 2", [
      FakeStep(1, rndDuration()),
      FakeStep(2, rndDuration()),
      FakeStep(3, rndDuration()),
    ])
  ]),
  Chain("Chain 3", [
    FakeStep(1, rndDuration()),
  ]),
]);
