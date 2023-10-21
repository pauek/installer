import 'dart:io';

import 'package:installer/installer.dart';
import 'package:installer/steps/step.dart';
import 'package:path/path.dart';

class IsJavaInstalled extends Step {
  IsJavaInstalled() : super("Determine if Java is installed");

  static final _rVersion = RegExp(r"^openjdk (?<version>[\d\.]+) ");

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
    final dirExists = await Directory(javaTarget).exists();
    if (!dirExists) {
      return false;
    }

    // WARNING: There used to be a check here to see if a
    // Java version was installed in the system, but Android
    // needs a specific Java version that they package with the
    // Android SDK (which we download separately).
    // So we check only if Java is our 'java' folder.

    final javaExe = join(javaTarget, "bin", "java.exe");
    final javaVersion = await _getVersion(javaExe);
    if (javaVersion == null) {
      return false;
    }
    
    await ctx.addBinary("java", dirname(javaExe), "java.exe");
    ctx.addVariable("JAVA_HOME", javaTarget);
    return true; // found!
  }
}
