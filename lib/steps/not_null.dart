import 'package:installer2/steps/step.dart';

class NotNull extends SinglePriorStep<bool, dynamic> {
  NotNull(Step step) : super([step]);

  @override
  Future<bool> run() async {
    final result = await input;
    return result != null;
  }
}
