import 'package:installer2/run_installer.dart';
import 'package:installer2/steps/add_binary.dart';
import 'package:installer2/steps/android-sdk/accept_android_licenses.dart';
import 'package:installer2/steps/android-sdk/cmdline_tools_missing.dart';
import 'package:installer2/steps/android-sdk/cmdline_tools_url.dart';
import 'package:installer2/steps/clone_github_repo.dart';
import 'package:installer2/steps/create_shortcut.dart';
import 'package:installer2/steps/decompress.dart';
import 'package:installer2/steps/download_file.dart';
import 'package:installer2/steps/flutter/flutter_config_android_sdk.dart';
import 'package:installer2/steps/git/git_get_download_url.dart';
import 'package:installer2/steps/git/git_missing.dart';
import 'package:installer2/steps/git/git_repository_missing.dart';
import 'package:installer2/steps/give_url.dart';
import 'package:installer2/steps/if.dart';
import 'package:installer2/steps/java/java_get_download_url.dart';
import 'package:installer2/steps/java/java_missing.dart';
import 'package:installer2/steps/move.dart';
import 'package:installer2/steps/node/firebase_missing.dart';
import 'package:installer2/steps/node/node_get_download_url.dart';
import 'package:installer2/steps/node/node_missing.dart';
import 'package:installer2/steps/nushell/configure_nushell.dart';
import 'package:installer2/steps/nushell/nushell_download_url.dart';
import 'package:installer2/steps/nushell/nushell_missing.dart';
import 'package:installer2/steps/rename.dart';
import 'package:installer2/steps/run_command.dart';
import 'package:installer2/steps/run_sdk_manager.dart';
import 'package:installer2/steps/step.dart';
import 'package:installer2/steps/vscode/vscode_missing.dart';

final r7zVersion = RegExp(r"^7-Zip \(r\) (?<version>[\d.]+) \(x86\)");
final install7z = Chain("7z", [
  GiveURL("https://www.7-zip.org/a/7zr.exe"),
  DownloadFile(),
  Move(into: "7z", forcedFilename: "7z.exe"),
  AddToEnv("7z", [
    Binary("7z", win: "7z.exe"),
  ])
]);

final installGit = Chain("Git", [
  If(
    GitMissing(),
    then: Chain.noPrefix([
      GitGetDownloadURL(),
      DownloadFile(),
      Decompress(into: "git"),
      AddToEnv("git", [
        Binary("git", win: "cmd/git.exe"),
      ])
    ]),
  ),
]);

final installFlutter = Chain("Flutter", [
  installGit,
  If(
    GitRepositoryMissing("flutter", flutterRepo),
    then: CloneGithubRepo("flutter", flutterRepo, branch: "stable"),
  ),
  AddToEnv("flutter", [
    Binary("flutter", win: "bin/flutter.bat", all: "bin/flutter"),
    Binary("dart", win: "bin/dart.bat", all: "bin/dart"),
  ]),
  RunCommand("dart", ["pub", "global", "activate", "flutterfire_cli"]),
]);

final installNode = If(
  NodeMissing(),
  then: Chain("Node", [
    NodeGetDownloadURL(),
    DownloadFile(),
    Decompress(into: "node"),
    AddToEnv("node", [
      Binary("node", win: "node.exe", all: "bin/node"),
      Binary("npm", win: "npm.cmd", all: "bin/npm"),
    ]),
  ]),
);

final installFirebaseCLI = Chain("FirebaseCLI", [
  installNode,
  If(
    FirebaseMissing(),
    then: RunCommand("npm", ["install", "-g", "firebase-tools"]),
  ),
]);

final installVSCode = Chain("VSCode", [
  If(
    VSCodeMissing(),
    then: Chain.noPrefix([
      GiveURL(
        "https://code.visualstudio.com"
        "/sha/download?build=stable&os=win32-x64-archive",
      ),
      DownloadFile("vscode.zip"),
      Decompress(into: "vscode"),
      AddToEnv("vscode", [
        Binary("code", win: "bin/code.cmd", all: "bin/code"),
      ]),
    ]),
  )
]);

final installJava = If(
  JavaMissing(),
  then: Chain.noPrefix([
    JavaGetDownloadURL(),
    DownloadFile(),
    Decompress(into: "java"),
    AddToEnv("java", [
      Binary("java", all: "bin/java"),
      EnvVariable("JAVA_HOME"),
    ])
  ]),
);

final installAndroidSDK = Chain("Android SDK", [
  installJava,
  If(
    CmdlineToolsMissing(),
    then: Chain.noPrefix([
      GetAndroidCmdlineToolsURL(),
      DownloadFile(),
      Decompress(into: "android-sdk/cmdline-tools"),
      Rename(from: "cmdline-tools", to: "latest"),
      AddToEnv("android-sdk", [
        Binary(
          "sdkmanager",
          win: r"cmdline-tools\latest\bin\sdkmanager.bat",
          all: "cmdline-tools/latest/bin/sdkmanager",
        ),
        Binary(
          "avdmanager",
          win: r"cmdline-tools\latest\bin\avdmanager.bat",
          all: "cmdline-tools/latest/bin/avdmanager",
        ),
      ]),
    ]),
  ),
  RunSdkManager([
    "platforms;android-33",
    "build-tools;33.0.1",
    "platform-tools",
  ]),
  AcceptAndroidLicenses(),
]);

final installNushell = Chain("Nushell", [
  If(
    NushellMissing(),
    then: Chain.noPrefix([
      GetNushellDownloadURL(),
      DownloadFile(),
      Decompress(into: "nu"),
      AddToEnv("nu", [
        Binary("nu", win: "nu.exe", all: "nu"),
      ])
    ]),
  )
]);

// final installFonts = Chain("Fonts", [
//   GetFontDownloadURL(fontName: "Iosevka"),
//   DownloadFile(),
//   Decompress(into: "fonts/Iosevka"),
//   RegisterFonts(),
// ]);

final finalSetup = Chain("Final Setup", [
  ConfigureNushell(),
  FlutterConfigAndroidSDK(),
  CreateShortcut(),
]);

void main(List<String> arguments) async {
  await runInstaller(
    Sequence([
      install7z,
      Parallel([
        installNushell,
        installVSCode,
        installFlutter,
        installAndroidSDK,
        installFirebaseCLI,
      ]),
      finalSetup,
    ]),
  );
}

// FIXME: Colores para las cosas
// FIXME: Isolates para el unzip, o algo equivalente
// FIXME: Obtener el SHA y mirar si tenemos el fichero
// FIXME: Opciones de línea de comandos para instalar selectivamente