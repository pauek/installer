import 'dart:math';

import 'package:installer2/steps/if.dart';
import 'package:installer2/steps/step.dart';
import 'package:installer2/utils.dart';

class FakeStep extends Step {
  final int number;
  final Duration duration;
  FakeStep(this.number, this.duration) : super("Fake Step $number");

  @override
  Future run() async {
    await Future.delayed(duration);
    return true;
  }
}

class ErrorStep extends Step {
  final String name;
  ErrorStep(this.name) : super("ErrorStep $name");

  @override
  Future run() async {
    throw InstallerError("ErrorStep $name giving the error.");
  }
}

class GiveValue extends Step {
  dynamic value;
  GiveValue(this.value) : super("Give $value");

  @override
  Future run() {
    return Future.value(value);
  }
}

final rnd = Random();

rndDuration() => Duration(milliseconds: rnd.nextInt(900) + 600);

final fakeInstaller = Sequence([
  Chain("Before", [
    FakeStep(0, Duration(seconds: 1)),
  ]),
  Parallel([
    Chain("Chain 1", [
      If(
        GiveValue(true),
        then: Chain("Subchain 1.1", [
          FakeStep(1, rndDuration()),
          FakeStep(2, rndDuration()),
          FakeStep(3, rndDuration()),
          FakeStep(4, rndDuration()),
        ]),
      ),
      FakeStep(1, rndDuration()),
      FakeStep(2, rndDuration()),
      FakeStep(3, rndDuration()),
      FakeStep(4, rndDuration()),
    ]),
    Chain("Chain 2", [
      FakeStep(1, rndDuration()),
      FakeStep(2, rndDuration()),
      FakeStep(3, rndDuration()),
      ErrorStep("A"),
    ]),
    Chain("Chain 3", [
      FakeStep(1, rndDuration()),
      ErrorStep("B"),
      FakeStep(2, rndDuration()),
      FakeStep(3, rndDuration()),
    ]),
  ]),
  Chain("After", [
    FakeStep(1, rndDuration()),
    FakeStep(2, rndDuration()),
  ]),
]);
