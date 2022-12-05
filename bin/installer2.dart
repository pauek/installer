import 'dart:io';

import 'package:console/console.dart';
import 'package:installer2/context.dart';
import 'package:installer2/log.dart';
import 'package:installer2/steps/clone_github_repository.dart';
import 'package:installer2/steps/decompress.dart';
import 'package:installer2/steps/download_file.dart';
import 'package:installer2/steps/git_check_installed.dart';
import 'package:installer2/steps/git_get_download_url.dart';
import 'package:installer2/steps/git_repository_missing.dart';
import 'package:installer2/steps/give_url.dart';
import 'package:installer2/steps/if.dart';
import 'package:installer2/steps/node_get_download_url.dart';
import 'package:installer2/steps/step.dart';
import 'package:installer2/utils.dart';
import 'package:path/path.dart';

Future<void> runInstaller(Step installer) async {
  Console.init();
  final homeDir = getHomeDir();
  await InstallerContext.init(
    targetDir: join(homeDir, "MobileDevelopment"),
    downloadDir: join(homeDir, "Downloads"),
  );
  Log.init(filename: "flutter-installer.log");
  ctx.addBinary("7z", "/Users/pauek/bin", "7zz");
  log.print("Setup: ok");

  // Console.hideCursor();
  Console.eraseDisplay(2);
  final lastPos = installer.setPos(CursorPosition(1, 1));
  Console.moveCursor(column: 1, row: 1);
  await installer.run();
  await log.close();
  Console.moveCursor(column: lastPos.column, row: lastPos.row);
  Console.write("[Press any key or close the terminal]\n");
  Console.showCursor();
  Console.readLine();
  exit(0); // Bug in Console??
}

const vscodeDownloadURL = "https://code.visualstudio.com"
    "/sha/download?build=stable&os=win32-x64-archive";

final installGit = If(
  GitNotInstalled(),
  then: Chain("Git", [
    GitGetDownloadURL(),
    DownloadFile(),
    Decompress(into: "git"),
  ]),
);

final installFlutter = Chain("Flutter", [
  installGit,
  If(
    GitRepositoryMissing("flutter", flutterGithubRepo),
    then: CloneGithubRepository("flutter", flutterGithubRepo),
  ),
]);

final installNode = Chain("Node", [
  NodeGetDownloadURL(),
  DownloadFile(),
  Decompress(into: "node"),
]);

final installVSCode = Chain("VSCode", [
  GiveURL(vscodeDownloadURL),
  DownloadFile("vscode.zip"),
  Decompress(into: "vscode"),
]);

void main(List<String> arguments) {
  runInstaller(
    Parallel([
      installNode,
      installVSCode,
      installFlutter,
    ]),
  );
}
