import 'package:console/console.dart';
import 'package:installer2/context.dart';
import 'package:installer2/log.dart';
import 'package:installer2/steps/test_steps.dart';
import 'package:installer2/utils.dart';
import 'package:path/path.dart';

Future<void> setup() async {
  Console.init();
  // final homeDir = getHomeDir();
  // await InstallerContext.init(
  //   targetDir: join(homeDir, "MobileDevelopment"),
  //   downloadDir: join(homeDir, "Downloads"),
  // );
  Log.init(filename: "flutter-installer.log");
  ctx.addBinary("7z", "/Users/pauek/bin", "7zz");
  Console.eraseDisplay(2);
  Console.moveCursor(row: 1, column: 1);
  // Console.hideCursor(); // Hace que se cuelgue el programa...
  log.print("Installer setup done\n");
}

void main(List<String> arguments) async {
  await setup();

  final installer = ShowResult(GiveFive());
  await installer.run();
}


/*

FlutterInstaller:
  CreateShortCut:
    ConfigNu:
      InstallFirebase: 
        DownloadDecompress(Node)
          Download7z
      InstallFlutterFire: 
        CloneFlutter: 
          DownloadDecompress(Git)
      DownloadDecompress(VSCode)
      DownloadDecompress(Nu)
      InstallAndroidPackages:
        DownloadDecompress(Java)
        DownloadDecompress(Android cmdline-tools)

*/