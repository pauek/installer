import 'package:installer/steps/step.dart';

class Delay extends SinglePriorStep {
  final Duration duration;
  Delay({required this.duration}) : super("Delay $duration");

  @override
  Future run() async {
    await Future.delayed(duration);
    return input;
  }
}
