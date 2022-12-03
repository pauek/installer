import 'dart:io';

import 'package:console/console.dart';
import 'package:installer2/context.dart';
import 'package:installer2/log.dart';
import 'package:installer2/steps/decompress.dart';
import 'package:installer2/steps/download_file.dart';
import 'package:installer2/steps/flutter_clone_repo.dart';
import 'package:installer2/steps/git_get_download_url.dart';
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
  await log.print("Installer setup ok");

  await func();

  log.close();
  Console.showCursor();
  exit(0); // Bug in Console??
}

void main(List<String> arguments) {
  withSetup(() async {
    final installer = FlutterCloneRepo(
      installGit: Decompress("git", DownloadFile(GitGetDownloadURL())),
    );
    installer.pos = CursorPosition(1, 1);
    await installer.run();
  });
}
