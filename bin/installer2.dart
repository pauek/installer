import 'dart:io';

import 'package:console/console.dart';
import 'package:installer2/context.dart';
import 'package:installer2/log.dart';
import 'package:installer2/steps/test_steps.dart';
import 'package:installer2/utils.dart';
import 'package:path/path.dart';

Future<void> withSetup(Future<void> Function() func) async {
  Console.init();
  final homeDir = getHomeDir();
  await InstallerContext.init(
    targetDir: join(homeDir, "MobileDevelopment"),
    downloadDir: join(homeDir, "Downloads"),
  );
  Log.init(filename: "flutter-installer.log");
  ctx.addBinary("7z", "/Users/pauek/bin", "7zz");
  Console.hideCursor(); // Hace que se cuelgue el programa??
  Console.eraseDisplay(2);
  log.print("Installer setup done\n");

  await func();

  Console.showCursor();
  exit(0); // Bug in Console??
}

void main(List<String> arguments) {
  withSetup(() async {
    final installer = ShowManyResults([
      GiveInteger(1),
      GiveInteger(2),
      ShowManyResults([
        GiveInteger(3),
        GiveInteger(4),
        GiveInteger(5),
      ]),
      GiveInteger(6),
      ShowManyResults([
        GiveInteger(7),
        GiveInteger(8),
      ])
    ]);
    installer.pos = CursorPosition(1, 1);
    await installer.run();
  });
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