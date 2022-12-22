import 'dart:math';

import 'package:installer2/config.dart';
import 'package:installer2/log.dart';
import 'package:installer2/run_installer.dart';
import 'package:installer2/steps/add_binary.dart';
import 'package:installer2/steps/android-sdk/accept_android_licenses.dart';
import 'package:installer2/steps/android-sdk/cmdline_tools_url.dart';
import 'package:installer2/steps/android-sdk/is_cmdline_tools_installed.dart';
import 'package:installer2/steps/clone_github_repo.dart';
import 'package:installer2/steps/create_shortcut.dart';
import 'package:installer2/steps/decompress.dart';
import 'package:installer2/steps/delay.dart';
import 'package:installer2/steps/download_file.dart';
import 'package:installer2/steps/fake_step.dart';
import 'package:installer2/steps/flutter/flutter_config_android_sdk.dart';
import 'package:installer2/steps/git/git_get_download_url.dart';
import 'package:installer2/steps/git/git_repository_present.dart';
import 'package:installer2/steps/git/is_git_installed.dart';
import 'package:installer2/steps/give_url.dart';
import 'package:installer2/steps/if.dart';
import 'package:installer2/steps/java/is_java_installed.dart';
import 'package:installer2/steps/java/java_get_download_url.dart';
import 'package:installer2/steps/move.dart';
import 'package:installer2/steps/node/is_firebase_cli_installed.dart';
import 'package:installer2/steps/node/is_node_installed.dart';
import 'package:installer2/steps/node/node_get_download_url.dart';
import 'package:installer2/steps/not.dart';
import 'package:installer2/steps/nushell/configure_nushell.dart';
import 'package:installer2/steps/nushell/is_nushell_installed.dart';
import 'package:installer2/steps/nushell/nushell_download_url.dart';
import 'package:installer2/steps/rename.dart';
import 'package:installer2/steps/run_command.dart';
import 'package:installer2/steps/run_sdk_manager.dart';
import 'package:installer2/steps/step.dart';
import 'package:installer2/steps/vscode/is_vscode_installed.dart';

i7z(Set<String> opts) {
  return Chain("7z", [
    GiveURL("https://www.7-zip.org/a/7zr.exe"),
    DownloadFile(),
    Move(into: "7z", forcedFilename: "7z.exe"),
    AddToEnv("7z", [Binary("7z", win: "7z.exe")])
  ]);
}

iGit(Set<String> opts) {
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

iFlutter(Set<String> opts) {
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

iNode(Set<String> opts) {
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

iFirebaseCLI(Set<String> opts) {
  return Chain("FirebaseCLI", [
    If(
      Not(IsFirebaseCliInstalled()),
      then: RunCommand("npm", ["install", "-g", "firebase-tools"]),
    ),
  ]);
}

iVSCode(Set<String> opts) {
  return Chain("VSCode", [
    If(
      (opts.contains("--force") ? GiveValue(true) : Not(IsVSCodeInstalled())),
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

iJavaJDK(Set<String> opts) {
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

iAndroidSdk(Set<String> opts) {
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

iNushell(Set<String> opts) {
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

iFinalSetup(Set<String> opts) {
  return Chain("Final Setup", [
    ConfigureNushell(),
    FlutterConfigAndroidSDK(),
    CreateShortcut(),
  ]);
}

// final installFonts = Chain("Fonts", [
//   GetFontDownloadURL(fontName: "Iosevka"),
//   DownloadFile(),
//   Decompress(into: "fonts/Iosevka"),
//   RegisterFonts(),
// ]);

class Option {
  String name, description;
  Step step;
  List<Option>? deps;
  Option(this.name, this.step, this.description, [this.deps]);

  Step? getStep(Set<String> args) {
    if (args.contains(name)) {
      return Chain(name, [
        step,
        if (deps != null) ...deps!.map((d) => d.step).toList(), // FIXME: wrong!
      ]);
    } else if (deps != null) {
      if (deps!.length == 1) {
        return deps!.single.getStep(args);
      } else {
        List<Step> chosen = [];
        for (final d in deps!) {
          final step = d.getStep(args);
          if (step != null) chosen.add(step);
        }
        return Parallel(chosen);
      }
    } else {
      return null;
    }
  }
}

bool removeCurrentInstallation = false;

void main(List<String> arguments) async {
  final args = arguments.where((a) => !a.startsWith("-")).toSet();
  final opts = arguments.where((a) => a.startsWith("-")).toSet();

  bool isSingle(String x) => (args.length == 1 && args.single == x);

  List<Option> installers = [
    Option("nu", iNushell(opts), "Nushell"),
    Option("vscode", iVSCode(opts), "Visual Studio Code"),
    Option("flutter", iFlutter(opts), "Flutter", [
      Option("git", iGit(opts), "Git"),
    ]),
    Option("android-sdk", iAndroidSdk(opts), "Android SDK", [
      Option("java", iJavaJDK(opts), "Java JDK"),
    ]),
    Option("firebase-cli", iFirebaseCLI(opts), "Firebase CLI", [
      Option("node", iNode(opts), "Node and npm"),
    ]),
  ];

  final longestName = installers.map((k) => k.name.length).reduce(max);

  if (isSingle("help")) {
    print("Installers: ");
    print("  ${"all".padRight(longestName)} - All below [default]");
    for (final c in installers) {
      print("  ${c.name.padRight(longestName)} - ${c.description}");
    }
    print("\nExample:");
    print("  flutter-installer.exe flutter android-sdk");
    print("");
    return;
  }

  List<Step> chosen = [];
  for (final i in installers) {
    final step = i.getStep(args);
    if (step != null) {
      chosen.add(step);
    }
  }

  await runInstaller(
    Sequence([
      i7z(opts),
      Parallel(chosen),
      if (isSingle("all")) iFinalSetup(opts),
    ]),
  );
}

// FIXME: Obtener el SHA y mirar si tenemos el fichero (por orden del tamaño del fichero)
// FIXME: Opciones de línea de comandos para instalar selectivamente
