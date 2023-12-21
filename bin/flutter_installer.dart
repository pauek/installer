import 'dart:io';
import 'dart:math';

import 'package:installer/installer.dart';
import 'package:installer/steps.dart';
import 'package:path/path.dart';

bool removeCurrentInstallation = false;

Step iFinalSetup() {
  return Chain("Final Setup", []);
}

final options = {
  "7z": Option("7z", i7z, "7z", -1),
  "nu": Option("nu", iNushell, "Nushell", -1, ["7z"]),
  "git": Option("git", iGit, "Git", 0, ["7z"]),
  "java": Option("java", iJavaJDK, "Java JDK", 0, ["7z"]),
  "vscode": Option("vscode", iVSCode, "Visual Studio Code", 0, ["7z"]),
  "flutter": Option("flutter", iFlutter, "Flutter", 0, ["git", "nu"]),
  "android-sdk": Option("android-sdk", iAndroidSdk, "Android SDK", 0, ["java", "nu"]),
};

final longestName = options.values.map((v) => v.name.length).reduce(max);

void showHelp(args) {
  print("Installers: ");
  print("  ${"all".padRight(longestName)} - All below [default]");
  for (final c in options.values) {
    print("  ${c.name.padRight(longestName)} - ${c.description}");
  }
  print("\nExample:");
  print("  installer flutter android-sdk");
  print("");
  exit(0);
}

List<Step> decideInstallers(Set<String> opts, Set<String> args) {
  log.print("info: Command-line arguments = $args");
  Map<String, Option> needed = Map.fromEntries(options.entries.where((elem) =>
      args.contains(elem.key) || args.contains("all") || args.isEmpty));

  log.print(
    "info: Selected installers = ${needed.keys.join(", ")}",
  );

  bool changes = true;
  while (changes) {
    Map<String, Option> alsoNeeded = {};
    for (final entry in needed.entries) {
      final opt = entry.value;
      final dependencyNames = opt.dependencies;
      if (dependencyNames != null) {
        for (final depName in dependencyNames) {
          Option? dep = options[depName];
          if (dep == null) {
            log.print(
              "WARNING: Dependency $depName of ${entry.key} is not an option!",
            );
          } else if (!needed.containsKey(depName)) {
            alsoNeeded[depName] = dep;
            if (opt.order <= dep.order) {
              dep.order = opt.order - 1;
            }
          }
        }
      }
    }
    needed.addAll(alsoNeeded);
    changes = alsoNeeded.isNotEmpty;
  }

  log.print(
    "info: Needed installers = ${needed.keys.join(", ")}",
  );

  List<Option> neededOptions = needed.values.toList();
  neededOptions.sort((a, b) => a.order - b.order);

  log.print(
    "info: Ordered installers = ${neededOptions.map((opt) => opt.name).join(", ")}",
  );
  final installers = neededOptions.map((opt) => opt.builder()).toList();
  return installers;
}

void main(List<String> argv) async {
  HttpOverrides.global = MyHttpOverrides();

  final res = argv.separate((String a) => a.startsWith("-"));
  final opts = Set<String>.from(res[0]);
  final args = Set<String>.from(res[1]);

  if (args.contains("help") || opts.contains("-h") || opts.contains("--help")) {
    showHelp(args);
  }

  final homeDir = getHomeDir();
  final sharedDownloadDir =
      await createSharedDownloadDir(installerCITMDownloadsDir);

  await InstallerContext.init(
    targetDir: join(homeDir, installerTargetDir),
    downloadDir: sharedDownloadDir ?? join(homeDir, windowsDownloadsDir),
  );

  Log.init(filename: installerLogFile);
  List<Step> installers = decideInstallers(opts, args);

  await runInstaller(
    Sequence([
      ...installers,
      Chain("env.nu", [ConfigureNushell()]),
      if (opts.contains("flutter") && opts.contains("android-sdk"))
        Chain("FlutterConfig", [FlutterConfigAndroidSDK()]),
      Chain("Shortcut", [CreateShortcut("Flutter Dev")]),
    ]),
  );
}

// FIXME: Obtener el SHA y mirar si tenemos el fichero (por orden del tamaño del fichero)
// FIXME: Opciones de línea de comandos para instalar selectivamente
