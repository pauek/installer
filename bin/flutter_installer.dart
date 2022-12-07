import 'package:installer2/run_installer.dart';
import 'package:installer2/steps/add_binary.dart';
import 'package:installer2/steps/android-sdk/accept_android_licenses.dart';
import 'package:installer2/steps/android-sdk/cmdline_tools_url.dart';
import 'package:installer2/steps/clone_github_repo.dart';
import 'package:installer2/steps/create_shortcut.dart';
import 'package:installer2/steps/decompress.dart';
import 'package:installer2/steps/download_file.dart';
import 'package:installer2/steps/flutter/flutter_config_android_sdk.dart';
import 'package:installer2/steps/fonts/get_font_download_url.dart';
import 'package:installer2/steps/fonts/register_fonts.dart';
import 'package:installer2/steps/git/git_get_download_url.dart';
import 'package:installer2/steps/git/git_repository_missing.dart';
import 'package:installer2/steps/give_url.dart';
import 'package:installer2/steps/if.dart';
import 'package:installer2/steps/java/java_get_download_url.dart';
import 'package:installer2/steps/node/node_get_download_url.dart';
import 'package:installer2/steps/not_null.dart';
import 'package:installer2/steps/nushell/configure_nushell.dart';
import 'package:installer2/steps/nushell/nushell_download_url.dart';
import 'package:installer2/steps/rename.dart';
import 'package:installer2/steps/run_command.dart';
import 'package:installer2/steps/run_sdk_manager.dart';
import 'package:installer2/steps/step.dart';
import 'package:installer2/steps/version_installed.dart';

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
    GitRepositoryMissing("flutter", flutterRepo),
    then: CloneGithubRepo("flutter", flutterRepo, branch: "stable"),
  ),
  AddBinaries("flutter", [
    Binary("flutter", win: "bin/flutter.bat", all: "bin/flutter"),
    Binary("dart", win: "bin/dart.bat", all: "bin/dart"),
  ]),
  RunCommand("dart", ["pub", "global", "activate", "flutterfire_cli"]),
]);

final installNode = Chain("Node", [
  NodeGetDownloadURL(),
  DownloadFile(),
  Decompress(into: "node"),
  AddBinaries("node", [
    Binary("node", win: "node.exe", all: "bin/node"),
    Binary("npm", win: "npm.cmd", all: "bin/npm"),
  ]),
]);

final installFirebaseCLI = Chain("FirebaseCLI", [
  installNode,
  RunCommand("npm", ["install", "-g", "firebase-tools"]),
]);

final installVSCode = Chain("VSCode", [
  GiveURL(
    "https://code.visualstudio.com"
    "/sha/download?build=stable&os=win32-x64-archive",
  ),
  DownloadFile("vscode.zip"),
  Decompress(into: "vscode"),
  AddBinaries("vscode", [
    Binary("code", win: "bin/code.cmd", all: "code"),
  ])
]);

final rJavaVersion = RegExp(r"^java (.*)$");

final installJava = If(
  NotNull(
    // FIXME: Buscar la versión mínima para Android SDK
    VersionInstalled("java", rJavaVersion),
  ),
  then: Chain("Java", [
    JavaGetDownloadURL(),
    DownloadFile(),
    Decompress(into: "java"),
    AddBinaries("java", [
      Binary("java", all: "bin/java"),
    ])
  ]),
);

final installAndroidSDK = Chain("Android SDK", [
  installJava,
  GetAndroidCmdlineToolsURL(),
  DownloadFile(),
  Decompress(into: "android-sdk/cmdline-tools"),
  Rename(from: "cmdline-tools", to: "latest"),
  AddBinaries("android-sdk", [
    Binary(
      "sdkmanager",
      win: "cmdline-tools/latest/bin/sdkmanager.bat",
      all: "cmdline-tools/latest/bin/sdkmanager",
    ),
    Binary(
      "avdmanager",
      win: "cmdline-tools/latest/bin/avdmanager.bat",
      all: "cmdline-tools/latest/bin/avdmanager",
    ),
  ]),
  RunSdkManager([
    "platforms;android-33",
    "build-tools;33.0.1",
    "platform-tools",
  ]),
  AcceptAndroidLicenses(),
]);

final installNushell = Chain("Nushell", [
  GetNushellDownloadURL(),
  DownloadFile(),
  Decompress(into: "nu"),
  AddBinaries("nu", [
    Binary("nu", win: "nu.exe", all: "nu"),
  ])
]);

final installFonts = Chain("Fonts", [
  GetFontDownloadURL(fontName: "Iosevka"),
  DownloadFile(),
  Decompress(into: "fonts/Iosevka"),
  RegisterFonts(),
]);

void main(List<String> arguments) {
  runInstaller(
    Sequence([
      Parallel([
        installFlutter,
        installAndroidSDK,
        installFirebaseCLI,
        installVSCode,
        installNushell,
        installFonts,
      ]),
      Chain("Final Setup", [
        ConfigureNushell(),
        FlutterConfigAndroidSDK(),
        CreateShortcut(),
      ]),
    ]),
  );
}
