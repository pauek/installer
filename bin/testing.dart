import 'package:installer/run_installer.dart';
import 'package:installer/steps/nushell/configure_nushell.dart';

void main(List<String> arguments) {
  runInstaller(
    ConfigureNushell(),
  );
}
