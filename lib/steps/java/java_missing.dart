import 'dart:io';

import 'package:installer2/context.dart';
import 'package:installer2/log.dart';
import 'package:installer2/steps/step.dart';
import 'package:installer2/utils.dart';
import 'package:path/path.dart';

class JavaMissing extends Step {
  JavaMissing();

  static final rJavaVersion = RegExp(r"^(?:java|openjdk) (?<version>[\d\.]+)$");

  Future<bool> runJavaVersion(String exe) async {
    final result = await Process.run(exe, ["--version"], runInShell: true);
    final match = rJavaVersion.firstMatch(result.stdout.trim());
    String? version = match?.namedGroup("version");
    if (version != null) {
      log.print("info: Java found, version '$version'.");
    }
    return version == null;
  }

  @override
  Future run() async {
    final result = await waitForInput();
    if (result is InstallerError) {
      return result;
    }
    return withMessage("Determining if Java is installed", () async {
      // Check Java in targetDir
      final javaTarget = join(ctx.targetDir, "java");
      if (await Directory(javaTarget).exists()) {
        final dirs = await dirList(javaTarget);
        if (dirs.length == 1) {
          final javaSdkDir = join(javaTarget, dirs[0]);
          final javaExe = join(javaSdkDir, "bin", "java.exe");
          if (await runJavaVersion(javaExe)) {
            ctx.addBinary("java", dirname(javaExe), "java.exe");
            ctx.addVariable("JAVA_HOME", javaSdkDir);
            return false; // Not missing!
          }
        }
      }
      // Try with system Java
      // FIXME: Check minimum version!
      return await runJavaVersion("java");
    });
  }
}
