import 'dart:io';

import 'package:installer/installer.dart';
import 'package:installer/steps/step.dart';
import 'package:path/path.dart';

class IsNodeInstalled extends Step {
  IsNodeInstalled() : super("Determine if node is installed");

  static final rNodeVersion = RegExp(r"^v(?<version>[\d\.]+)");

  Future<String?> _getVersion(String nodeExe) async {
    final result = await Process.run(nodeExe, ["--version"], runInShell: true);
    final match = rNodeVersion.firstMatch(result.stdout.trim());
    String? version = match?.namedGroup("version");
    if (version != null) {
      log.print("info: Node version found: '$version'.");
    }
    return version;
  }

  @override
  Future run() async {
    final nodeTargetDir = join(ctx.targetDir, "node");
    if (await Directory(nodeTargetDir).exists()) {
      final dirs = await dirList(nodeTargetDir);
      if (dirs.length == 1) {
        final nodeDir = dirs[0];
        final nodeExe = join(nodeDir, "node.exe");
        final nodeVersion = await _getVersion(nodeExe);
        if (nodeVersion != null) {
          await ctx.addBinary("node", nodeDir, "node.exe");
          await ctx.addBinary("npm", nodeDir, "npm.cmd");
          return true;
        }
      }
    }
    log.print("info: Node not found on Path.");
    return false;
  }
}
