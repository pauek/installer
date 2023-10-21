import 'dart:io';

import 'package:installer/installer.dart';
import 'package:installer/steps/step.dart';
import 'package:path/path.dart';

class IsGitInstalled extends Step {
  IsGitInstalled() : super("Check if git is installed");

  final _rVersion = RegExp(r"^git version (?<version>[\w\.]+)");

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
    final gitTargetDir = join(ctx.targetDir, "git");
    if (await Directory(gitTargetDir).exists()) {
      final gitDir = join(gitTargetDir, "cmd");
      final gitExe = join(gitDir, "git.exe");
      final gitVersion = await _getVersion(gitExe);
      if (gitVersion != null) {
        await ctx.addBinary("git", gitDir, "git.exe");
        return true;
      }
    }
    log.print("info: Git not found in ${ctx.targetDir}.");
    return false;
  }
}
