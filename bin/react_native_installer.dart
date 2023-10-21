import 'package:installer/installer.dart';
import 'package:installer/steps.dart';
import 'package:path/path.dart';

void main(List<String> argv) async {
  // Open log
  Log.init(filename: "react-native-installer.log");

  // Set Context
  final homeDir = getHomeDir();
  await InstallerContext.init(
    targetDir: join(homeDir, "ReactNativeDev"),
    downloadDir: join(homeDir, "Downloads"),
  );

  // Run installer
  await runInstaller(
    Sequence([
      i7z(),
      Parallel([
        iNushell(),
        iGit(),
        iNode(),
        iVSCode(),
        Chain("Android SDK", [
          iJavaJDK(),
          iAndroidSdk(),
        ]),
      ]),
      Chain("Final Setup", [
        ConfigureNushell(),
        CreateShortcut("React Native Dev"),
      ]),
    ]),
  );
}
