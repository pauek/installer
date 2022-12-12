import 'package:installer2/run_installer.dart';
import 'package:installer2/steps/nushell/configure_nushell.dart';

void main(List<String> arguments) {
  runInstaller(
    ConfigureNushell(),
  );
}
