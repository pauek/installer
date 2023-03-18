import 'dart:io';
import 'dart:math';

import 'package:installer/context.dart';
import 'package:installer/installers.dart';
import 'package:installer/log.dart';
import 'package:installer/option.dart';
import 'package:installer/run_installer.dart';
import 'package:installer/steps/step.dart';
import 'package:installer/utils.dart';
import 'package:path/path.dart';

bool removeCurrentInstallation = false;

const installers = [
  Option("7z", i7z, "7z"),
  Option("nu", iNushell, "Nushell"),
  Option("git", iGit, "Git"),
  Option("java", iJavaJDK, "Java JDK"),
  Option("node", iNode, "Node and npm"),
  Option("vscode", iVSCode, "Visual Studio Code"),
  Option("flutter", iFlutter, "Flutter", ["git"]),
  Option("android-sdk", iAndroidSdk, "Android SDK", ["java"]),
  Option("firebase-cli", iFirebaseCLI, "Firebase CLI", ["node"]),
];

final longestName = installers.map((k) => k.name.length).reduce(max);

void showHelp(args) {
  print("Installers: ");
  print("  ${"all".padRight(longestName)} - All below [default]");
  for (final c in installers) {
    print("  ${c.name.padRight(longestName)} - ${c.description}");
  }
  print("\nExample:");
  print("  installer flutter android-sdk");
  print("");
  exit(0);
}

List<Step> decideInstallers(Set<String> opts, Set<String> args) {
  List<bool> needed = installers.map((x) => false).toList();

  depends(Option a, Option b) => a.dependencies?.contains(b.name) ?? false;

  for (var i = 0; i < installers.length; i++) {
    needed[i] = installers.any((x) => depends(x, installers[i]));
  }

  List<Step> chosen = [];
  for (var i = 0; i < installers.length; i++) {
    if (needed[i]) {
      chosen.add(installers[i].builder(opts));
    }
  }
  return chosen;
}

void main(List<String> argv) async {
  final res = argv.separate((String a) => a.startsWith("-"));
  final opts = Set<String>.from(res[0]), args = Set<String>.from(res[1]);

  bool isSingle(x) => (args.length == 1 && args.single == x);

  if (isSingle("help")) {
    showHelp(args);
  }

  List<Step> installers = decideInstallers(opts, args);

  Log.init(filename: "flutter-installer.log");

  final homeDir = getHomeDir();
  await InstallerContext.init(
    targetDir: join(homeDir, "FlutterDev"),
    downloadDir: join(homeDir, "Downloads"),
  );

  await runInstaller(
    Sequence([
      i7z(opts),
      ...installers,
      if (isSingle("all")) iFinalSetup(opts),
    ]),
  );
}

// FIXME: Obtener el SHA y mirar si tenemos el fichero (por orden del tamaño del fichero)
// FIXME: Opciones de línea de comandos para instalar selectivamente
