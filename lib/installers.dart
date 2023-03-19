import 'package:installer/config.dart';
import 'package:installer/steps/add_binary.dart';
import 'package:installer/steps/android-sdk/accept_android_licenses.dart';
import 'package:installer/steps/android-sdk/cmdline_tools_url.dart';
import 'package:installer/steps/android-sdk/is_cmdline_tools_installed.dart';
import 'package:installer/steps/clone_github_repo.dart';
import 'package:installer/steps/decompress.dart';
import 'package:installer/steps/delay.dart';
import 'package:installer/steps/download_file.dart';
import 'package:installer/steps/git/git_get_download_url.dart';
import 'package:installer/steps/git/git_repository_present.dart';
import 'package:installer/steps/git/is_git_installed.dart';
import 'package:installer/steps/give_url.dart';
import 'package:installer/steps/if.dart';
import 'package:installer/steps/java/is_java_installed.dart';
import 'package:installer/steps/java/java_get_download_url.dart';
import 'package:installer/steps/move.dart';
import 'package:installer/steps/node/is_firebase_cli_installed.dart';
import 'package:installer/steps/node/is_node_installed.dart';
import 'package:installer/steps/node/node_get_download_url.dart';
import 'package:installer/steps/not.dart';
import 'package:installer/steps/nushell/is_nushell_installed.dart';
import 'package:installer/steps/nushell/nushell_download_url.dart';
import 'package:installer/steps/rename.dart';
import 'package:installer/steps/run_command.dart';
import 'package:installer/steps/run_sdk_manager.dart';
import 'package:installer/steps/step.dart';
import 'package:installer/steps/vscode/is_vscode_installed.dart';

Step i7z() {
  return Chain("7z", [
    GiveURL("https://www.7-zip.org/a/7zr.exe"),
    DownloadFile(),
    Move(into: "7z", forcedFilename: "7z.exe"),
    AddToEnv("7z", [Binary("7z", win: "7z.exe")])
  ]);
}

Step iGit() {
  return Chain("Git", [
    If(
      Not(IsGitInstalled()),
      then: Chain.noPrefix([
        GitGetDownloadURL(),
        DownloadFile(),
        Decompress(into: "git"),
        AddToEnv("git", [
          Binary("git", win: r"cmd\git.exe"),
        ])
      ]),
    ),
  ]);
}

Step iFlutter() {
  return Chain("Flutter", [
    If(
      Not(GitRepositoryPresent("flutter", flutterRepo)),
      then: CloneGithubRepo("flutter", flutterRepo, branch: "stable"),
    ),
    AddToEnv("flutter", [
      Binary("flutter", win: r"bin\flutter.bat", all: "bin/flutter"),
      Binary("dart", win: r"bin\dart.bat", all: "bin/dart"),
    ]),
    RunCommand("dart", ["pub", "global", "activate", "flutterfire_cli"]),
  ]);
}

Step iNode() {
  return If(
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
}

Step iFirebaseCLI() {
  return Chain("FirebaseCLI", [
    If(
      Not(IsFirebaseCliInstalled()),
      then: RunCommand("npm", ["install", "-g", "firebase-tools"]),
    ),
  ]);
}

Step iVSCode() {
  return Chain("VSCode", [
    If(
      Not(IsVSCodeInstalled()),
      then: Chain.noPrefix([
        GiveURL(vscodeURL),
        DownloadFile("vscode.zip"),
        Decompress(into: "vscode"),
        AddToEnv("vscode", [
          Binary("code", win: r"bin\code.cmd", all: "bin/code"),
        ]),
      ]),
    )
  ]);
}

Step iJavaJDK() {
  return If(
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
}

Step iAndroidSdk() {
  return Chain("Android SDK", [
    If(
      Not(IsCmdlineToolsInstalled()),
      then: Chain.noPrefix([
        GetAndroidCmdlineToolsURL(),
        DownloadFile(),
        Decompress(into: r"android-sdk\cmdline-tools"),
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
    RunSdkManager(
      ["platforms;android-33", "build-tools;33.0.1", "platform-tools"],
    ),
    AcceptAndroidLicenses(),
  ]);
}

Step iNushell() {
  return Chain("Nushell", [
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
}
