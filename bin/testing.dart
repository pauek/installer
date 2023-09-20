import 'package:installer/context.dart';
import 'package:installer/log.dart';
import 'package:installer/run_installer.dart';
import 'package:installer/steps/nushell/configure_nushell.dart';
import 'package:installer/utils.dart';
import 'package:path/path.dart';

void main(List<String> arguments) async {
  Log.init(filename: "flutter-installer.log");

  final homeDir = getHomeDir();
  await InstallerContext.init(
    targetDir: join(homeDir, "FlutterDev"),
    downloadDir: join(homeDir, "Downloads"),
  );
  runInstaller(
    ConfigureNushell(),
  );
}
