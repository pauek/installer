import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:installer/installer.dart';
import 'package:installer/steps/step.dart';
import 'package:path/path.dart';

const github = "https://raw.githubusercontent.com";
const route = "/nushell/nushell/main/crates/nu-utils/src/sample_config/";
const magicLine = "### ------- pauek/installer ------- ###";

Future<String> getNuPath(name) async {
  final output = await getCommandOutput(
    ctx.getBinary("nu"),
    ["-c", "\$nu.$name-path"],
  );
  return output.trim();
}

const defaultEnvFileLines = r'''
let pathType = ($env.Path | describe)
if $pathType == string {
    # Fix de un bug de Nushell? El Path en Windows se hereda con los ";"
    $env.Path = ($env.Path | split column ';' | transpose | get column1)
}

$env.PROMPT_INDICATOR = {|| "> " }
$env.PROMPT_INDICATOR_VI_INSERT = {|| ": " }
$env.PROMPT_INDICATOR_VI_NORMAL = {|| "> " }
$env.PROMPT_MULTILINE_INDICATOR = {|| "::: " }
''';

const addPathsAndVariables = r'''
let pathDirs = [
    'AppData\Local\Pub\Cache\bin',
    'FlutterDev\7z',
    'FlutterDev\git\cmd',
    'FlutterDev\node\node',
    'FlutterDev\java\bin',
    'FlutterDev\vscode\bin',
    'FlutterDev\flutter\bin',
    'FlutterDev\android-sdk\cmdline-tools\latest\bin',
    'FlutterDev\android-sdk\platform-tools\bin',
    'dart-sdk\bin',
]
let absoluteDirs = ($pathDirs | each {|dir| $'($env.USERPROFILE)\($dir)' })
$env.Path = ($env.Path | prepend $absoluteDirs)
$env.JAVA_HOME = $'($env.USERPROFILE)\FlutterDev\java'
''';

Future<List<String>> defaultNuFileLines(String which) async {
  if (which == "env") {
    return defaultEnvFileLines.split("\n");
  } else {
    final path = await getNuPath(which);
    await ensureDir(dirname(path));
    final url = "$github${route}default_$which.nu";
    final response = await http.get(Uri.parse(url));
    return response.body.trim().split("\n");
  }
}

String dartPubDir() {
  final home = getHomeDir();
  if (Platform.isWindows) {
    return "$home\\AppData\\Local\\Pub\\Cache\\bin";
  } else if (Platform.isMacOS || Platform.isLinux) {
    return "$home/.pub-cache/bin";
  } else {
    return installerError("Platform not supported");
  }
}

String get endl {
  if (Platform.isWindows) {
    return "\r\n";
  } else if (Platform.isLinux) {
    return "\n";
  } else if (Platform.isMacOS) {
    return "\n"; // "\r" ??
  } else {
    return installerError("Platform not supported");
  }
}

String get pathVariable {
  if (Platform.isWindows) {
    return "Path";
  } else if (Platform.isLinux || Platform.isMacOS) {
    return "PATH";
  } else {
    return installerError("Platform not supported");
  }
}

String addEndl(String line) => "$line$endl";

Future<void> addLinesToFile(String path, List<String> lines) async {
  final file = await File(path).open(mode: FileMode.writeOnlyAppend);
  log.print("info: Added to $path:");
  for (final line in lines) {
    log.print("   >> $line");
  }
  await file.writeString(lines.map(addEndl).join(""));
  await file.close();
}

Future<List<String>> getFileLines(String which, String path) async {
  if (await File(path).exists()) {
    return await File(path).readAsLines();
  } else {
    return await defaultNuFileLines(which);
  }
}

Future addOrReplaceLines(
  String which,
  List<String> fileLines,
  List<String> newLines,
) async {
  if (fileLines.contains(magicLine)) {
    // If they exist, remove previous inserted lines
    final begin = fileLines.indexOf(magicLine);
    final end = fileLines.indexOf(magicLine, begin + 1);
    if (end == -1) {
      installerError("Found only one magic line in Nu's $which file");
    }
    fileLines.removeRange(begin, end + 1);
  }
  fileLines.addAll([magicLine, ...newLines, magicLine]);
}

class FileInfo {
  String path, dir, filename;
  FileInfo({required this.path, required this.dir, required this.filename});
}

class ConfigureNushell extends SinglePriorStep {
  ConfigureNushell() : super("Configure Nushell");

  @override
  Future run() async {
    final configFilePath = await getNuPath("config");
    final envFilePath = await getNuPath("env");

    // Read config files' lines
    final configLines = await getFileLines("config", configFilePath);
    final envLines = await getFileLines("env", envFilePath);

    // Change Path
    Set<String> envpath = {}; // deduplicate
    for (final path in ctx.binaries.values) {
      envpath.add(dirname(path));
    }
    // Add or replace path
    addOrReplaceLines("env", envLines, addPathsAndVariables.split("\n"));

    // Add or replace banner suppression
    addOrReplaceLines("config", configLines, [
      "\$env.config = {",
      "  show_banner: false",
      "}",
    ]);

    await File(configFilePath).writeAsString(configLines.join(endl) + endl);
    await File(envFilePath).writeAsString(envLines.join(endl) + endl);

    return true;
  }
}
