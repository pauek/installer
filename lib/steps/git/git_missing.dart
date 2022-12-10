import 'dart:io';

import 'package:installer2/context.dart';
import 'package:installer2/log.dart';
import 'package:installer2/steps/step.dart';
import 'package:installer2/utils.dart';
import 'package:path/path.dart';

class GitMissing extends Step {
  final _rVersion = RegExp(r"^git version (?<version>[\d\.]+)$");

  Future<String?> _getVersion(String gitExe) async {
    final result = await Process.run(gitExe, ["--version"], runInShell: true);
    final match = _rVersion.firstMatch(result.stdout.trim());
    String? version = match?.namedGroup("version");
    if (version != null) {
      log.print("info: Git found, version '$version'.");
    }
    return version;
  }

  @override
  Future run() async {
    final result = await waitForInput();
    if (result is InstallerError) {
      return result;
    }
    return withMessage("Determining if Git is installed", () async {
      final gitTargetDir = join(ctx.targetDir, "git");
      if (await Directory(gitTargetDir).exists()) {
        final gitDir = join(gitTargetDir, "cmd");
        final gitExe = join(gitDir, "git.exe");
        final gitVersion = await _getVersion(gitExe);
        if (gitVersion != null) {
          ctx.addBinary("git", gitDir, "git.exe");
          return false; // Not missing!
        }
      }
      // Try with system
      final systemVersion = await _getVersion("git");
      if (systemVersion == null) {
        log.print("info: Git not found in system");
      }
      return systemVersion == null;
    });
  }
}
