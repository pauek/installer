import 'package:installer/installer.dart';
import 'package:installer/steps.dart';
import 'package:path/path.dart';

void main(List<String> arguments) async {
  Log.init(filename: "flutter-installer.log");

  final homeDir = getHomeDir();
  await InstallerContext.init(
    targetDir: join(homeDir, installerTargetDir),
    downloadDir: join(homeDir, "Downloads"),
  );
  runInstaller(
    ConfigureNushell(),
  );
}
