import 'dart:io';

import 'package:installer2/context.dart';
import 'package:installer2/log.dart';
import 'package:installer2/steps/step.dart';
import 'package:installer2/utils.dart';
import 'package:path/path.dart';

class NodeMissing extends Step {
  static final rNodeVersion = RegExp(r"^v(?<version>[\d\.]+)");

  Future<String?> _getVersion(String nodeExe) async {
    final result = await Process.run(nodeExe, ["--version"], runInShell: true);
    final match = rNodeVersion.firstMatch(result.stdout.trim());
    String? version = match?.namedGroup("version");
    if (version != null) {
      log.print("info: Node found, version '$version'.");
    }
    return version;
  }

  @override
  Future run() async {
    final result = await waitForInput();
    if (result is InstallerError) {
      return result;
    }
    return withMessage("Determining if Node is installed", () async {
      final nodeTargetDir = join(ctx.targetDir, "node");
      if (await Directory(nodeTargetDir).exists()) {
        final dirs = await dirList(nodeTargetDir);
        if (dirs.length == 1) {
          final nodeDir = join(nodeTargetDir, dirs[0]);
          final nodeExe = join(nodeDir, "node.exe");
          final nodeVersion = await _getVersion(nodeExe);
          if (nodeVersion != null) {
            ctx.addBinary("node", nodeDir, "node.exe");
            ctx.addBinary("npm", nodeDir, "npm.cmd");
            return false; // Not missing!
          }
        }
      }
      // Try with system
      final nodeVersion = await _getVersion("node");
      if (nodeVersion == null) {
        log.print("Node not found on Path");
      }
      return nodeVersion == null;
    });
  }
}
