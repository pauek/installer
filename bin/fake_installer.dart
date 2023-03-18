import 'package:installer/run_installer.dart';
import 'package:installer/steps/fake_step.dart';

void main(List<String> args) {
  runInstaller(fakeInstaller);
}
