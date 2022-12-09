import 'package:installer2/steps/step.dart';
import 'package:installer2/utils.dart';

class NotNull extends SinglePriorStep {
  NotNull(Step step) : super(step);

  @override
  Future run() async {
    final result = await input.run();
    if (result is InstallerError) {
      return result;
    }
    return result != null;
  }
}
