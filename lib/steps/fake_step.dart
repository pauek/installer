import 'dart:math';

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
  }
}

final rnd = Random();

rndDuration() => Duration(milliseconds: rnd.nextInt(1800) + 1200);

fakeChain(int number) {
  int steps = rnd.nextInt(6) + 1;
  return Chain("Chain $number", [
    for (int i = 0; i < steps; i++) FakeStep(i + 1, rndDuration()),
  ]);
}

final fakeInstaller = Parallel([
  for (int i = 0; i < 5; i++) fakeChain(i + 1),
]);
