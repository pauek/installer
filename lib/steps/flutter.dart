import 'package:installer2/steps/step.dart';
import 'package:installer2/steps/types.dart';

class InstallFlutter extends SinglePriorStep {
  InstallFlutter(super.step);

  @override
  Future<Value> run() async {
    await input;
    return Value();
  }
}
