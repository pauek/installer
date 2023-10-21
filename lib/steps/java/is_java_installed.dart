import 'dart:io';

import 'package:installer/installer.dart';
import 'package:installer/steps/step.dart';
import 'package:path/path.dart';

class IsJavaInstalled extends Step {
  IsJavaInstalled() : super("See if Java is missing");

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
          return true; // found!
        }
      }
    }
    // WARNING: There used to be a check here to see if a
    // Java version was installed in the system, but Android
    // needs a specific Java version that they package with the
    // Android SDK (which we download separately).
    return false;
  }
}
