import 'dart:io';

import 'package:installer2/context.dart';
import 'package:installer2/log.dart';
import 'package:installer2/steps/step.dart';
import 'package:installer2/utils.dart';
import 'package:path/path.dart';

class JavaMissing extends Step {
  JavaMissing() : super("See if Java is missing");

  static final _rVersion = RegExp(r"^(?:java|openjdk) (?<version>[\d\.]+) ");

  Future<String?> _getVersion(String exe) async {
    final result = await Process.run(exe, ["--version"], runInShell: true);
    final match = _rVersion.firstMatch(result.stdout.trim());
    String? version = match?.namedGroup("version");
    if (version != null) {
      log.print("info: Java found, version '$version'.");
    }
    return version;
  }

  @override
  Future run() async {
    // Check Java in targetDir
    final javaTarget = join(ctx.targetDir, "java");
    if (await Directory(javaTarget).exists()) {
      final dirs = await dirList(javaTarget);
      if (dirs.length == 1) {
        final javaSdkDir = dirs[0];
        final javaExe = join(javaSdkDir, "bin", "java.exe");
        final javaVersion = await _getVersion(javaExe);
        if (javaVersion != null) {
          ctx.addBinary("java", dirname(javaExe), "java.exe");
          ctx.addVariable("JAVA_HOME", javaSdkDir);
          return false; // Not missing!
        }
      }
    }
    // Try with system Java
    // FIXME: Check minimum version!
    final systemVersion = await _getVersion("java");
    if (systemVersion == null) {
      log.print("Warning: java not found on system.");
    }
    return systemVersion == null;
  }
}
