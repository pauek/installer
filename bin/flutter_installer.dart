import 'package:installer2/run_installer.dart';
import 'package:installer2/steps/add_binary.dart';
import 'package:installer2/steps/android-sdk/accept_android_licenses.dart';
import 'package:installer2/steps/android-sdk/is_cmdline_tools_installed.dart';
import 'package:installer2/steps/android-sdk/cmdline_tools_url.dart';
import 'package:installer2/steps/clone_github_repo.dart';
import 'package:installer2/steps/create_shortcut.dart';
import 'package:installer2/steps/decompress.dart';
import 'package:installer2/steps/delay.dart';
import 'package:installer2/steps/download_file.dart';
import 'package:installer2/steps/flutter/flutter_config_android_sdk.dart';
import 'package:installer2/steps/git/git_get_download_url.dart';
import 'package:installer2/steps/git/is_git_installed.dart';
import 'package:installer2/steps/git/git_repository_present.dart';
import 'package:installer2/steps/give_url.dart';
import 'package:installer2/steps/if.dart';
import 'package:installer2/steps/java/java_get_download_url.dart';
import 'package:installer2/steps/java/is_java_installed.dart';
import 'package:installer2/steps/move.dart';
import 'package:installer2/steps/node/is_firebase_cli_installed.dart';
import 'package:installer2/steps/node/node_get_download_url.dart';
import 'package:installer2/steps/node/is_node_installed.dart';
import 'package:installer2/steps/not.dart';
import 'package:installer2/steps/nushell/configure_nushell.dart';
import 'package:installer2/steps/nushell/nushell_download_url.dart';
import 'package:installer2/steps/nushell/is_nushell_installed.dart';
import 'package:installer2/steps/rename.dart';
import 'package:installer2/steps/run_command.dart';
import 'package:installer2/steps/run_sdk_manager.dart';
import 'package:installer2/steps/step.dart';
import 'package:installer2/steps/vscode/is_vscode_installed.dart';

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
    Not(IsGitInstalled()),
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
    Not(GitRepositoryPresent("flutter", flutterRepo)),
    then: CloneGithubRepo("flutter", flutterRepo, branch: "stable"),
  ),
  AddToEnv("flutter", [
    Binary("flutter", win: "bin/flutter.bat", all: "bin/flutter"),
    Binary("dart", win: "bin/dart.bat", all: "bin/dart"),
  ]),
  RunCommand("dart", ["pub", "global", "activate", "flutterfire_cli"]),
]);

final installNode = If(
  Not(IsNodeInstalled()),
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
    Not(IsFirebaseCliInstalled()),
    then: RunCommand("npm", ["install", "-g", "firebase-tools"]),
  ),
]);

final installVSCode = Chain("VSCode", [
  If(
    Not(IsVSCodeInstalled()),
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
  Not(IsJavaInstalled()),
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
    Not(IsCmdlineToolsInstalled()),
    then: Chain.noPrefix([
      GetAndroidCmdlineToolsURL(),
      DownloadFile(),
      Decompress(into: "android-sdk/cmdline-tools"),
      Delay(duration: Duration(milliseconds: 500)),
      Rename(from: "cmdline-tools", to: "latest"),
      AddToEnv("android-sdk", [
        Binary(
          "sdkmanager",
          win: r"cmdline-tools\latest\bin\sdkmanager.bat",
          all: "cmdline-tools/latest/bin/sdkmanager",
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
    Not(IsNushellInstalled()),
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

// FIXME: Obtener el SHA y mirar si tenemos el fichero (por orden del tamaño del fichero)
// FIXME: Opciones de línea de comandos para instalar selectivamente