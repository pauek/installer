import 'dart:io';

import 'package:installer/installer.dart';
import 'package:path/path.dart';

class EnvVar {
  String variable, value;
  EnvVar(this.variable, this.value);
}

class InstallerContext {
  String targetDir;
  String downloadDir;

  final Set<String> _path = {};
  final Map<String, String> _binaries = {};
  final Map<String, String> _variables = {};

  InstallerContext._(this.targetDir, this.downloadDir);

  List<String> get path => _path.toList();

  Map<String, String> get environment => _variables;
  List<EnvVar> get variableList =>
      _variables.entries.map((e) => EnvVar(e.key, e.value)).toList();

  Map<String, String> get binaries => _binaries;

  void addBinary(String cmd, String dir, String filename) {
    _path.add(dirname(dir));
    _binaries[cmd] = join(dir, filename);
  }

  addVariable(String variable, String value) {
    log.print("info: Added variable '$variable' = '$value'.");
    _variables[variable] = value;
  }

  String getBinary(String cmd) => _binaries[cmd] ?? cmd;
  String? getVariable(String variable) => _variables[variable];

  static InstallerContext? _instance;

  static Future<void> init({
    required String targetDir,
    required String downloadDir,
  }) async {
    await Directory(targetDir).create(recursive: true);
    await Directory(downloadDir).create(recursive: true);
    _instance = InstallerContext._(targetDir, downloadDir);
  }
}

InstallerContext get ctx {
  if (InstallerContext._instance == null) {
    return installerError("Call InstallerContext.init(...) first!");
  }
  return InstallerContext._instance!;
}
