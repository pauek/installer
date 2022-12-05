import 'package:installer2/steps/add_binary.dart';
import 'package:installer2/steps/clone_github_repository.dart';
import 'package:installer2/steps/decompress.dart';
import 'package:installer2/steps/download_file.dart';
import 'package:installer2/steps/git_get_download_url.dart';
import 'package:installer2/steps/git_repository_missing.dart';
import 'package:installer2/steps/give_url.dart';
import 'package:installer2/steps/if.dart';
import 'package:installer2/steps/java_get_download_url.dart';
import 'package:installer2/steps/node_get_download_url.dart';
import 'package:installer2/steps/not_null.dart';
import 'package:installer2/steps/run_command.dart';
import 'package:installer2/steps/step.dart';
import 'package:installer2/steps/version_installed.dart';

import 'run_installer.dart';

const vscodeDownloadURL = "https://code.visualstudio.com"
    "/sha/download?build=stable&os=win32-x64-archive";

final installGit = Chain("Git", [
  GitGetDownloadURL(),
  DownloadFile(),
  Decompress(into: "git"),
]);

final rGitVersion = RegExp(r"^git version (.*)$");
final installFlutter = Chain("Flutter", [
  If(
    NotNull(VersionInstalled("git", rGitVersion)),
    then: installGit,
  ),
  If(
    GitRepositoryMissing("flutter", flutterGithubRepo),
    then: CloneGithubRepository("flutter", flutterGithubRepo),
  ),
  AddBinaries("flutter", [
    Binary("flutter", "bin/futter"),
    Binary("dart", "bin/dart"),
  ]),
  RunCommand("dart pub global activate flutterfire_cli"),
]);

final installNode = Chain("Node", [
  NodeGetDownloadURL(),
  DownloadFile(),
  Decompress(into: "node"),
  AddBinaries("node", [
    Binary("node", {
      "win": "node",
      "darwin": "bin/node",
      "linux": "bin/node",
    })
  ])
]);

final installFirebaseCLI = Chain("FirebaseCLI", [
  installNode,
  RunCommand("node install -g firebase-tools"),
]);

final installVSCode = Chain("VSCode", [
  GiveURL(vscodeDownloadURL),
  DownloadFile("vscode.zip"),
  Decompress(into: "vscode"),
]);

final rJavaVersion = RegExp(r"^java (.*)$");

final installJava = If(
  NotNull(
    VersionInstalled("java", rJavaVersion),
  ),
  then: Chain("Java", [
    JavaGetDownloadURL(),
    DownloadFile(),
    Decompress(into: "java"),
    AddBinaries("java", [Binary("java", "bin/java")])
  ]),
);

void main(List<String> arguments) {
  runInstaller(
    Parallel([
      // installFlutter,
      // installVSCode,
      installFirebaseCLI,
      // installJava,
    ]),
  );
}
