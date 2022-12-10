import 'dart:io';

import 'package:installer2/context.dart';
import 'package:installer2/log.dart';
import 'package:installer2/steps/step.dart';
import 'package:installer2/utils.dart';
import 'package:path/path.dart';

class FirebaseMissing extends Step {
  static final _rVersion = RegExp(r"^(?<version>[\d\.]+)");

  Future<bool> _getVersion(String exe) async {
    final result = await Process.run(exe, ["--version"], runInShell: true);
    final match = _rVersion.firstMatch(result.stdout.trim());
    String? version = match?.namedGroup("version");
    if (version != null) {
      log.print("info: Firebase found, version '$version'.");
    }
    return version == null;
  }

  @override
  Future run() async {
    final result = await waitForInput();
    if (result is InstallerError) {
      return result;
    }
    return withMessage("Determining if firebase is installed", () async {
      final nodeTargetDir = join(ctx.targetDir, "node");
      if (await Directory(nodeTargetDir).exists()) {
        final dirs = await dirList(nodeTargetDir);
        if (dirs.length == 1) {
          final firebaseDir = join(nodeTargetDir, dirs[0]);
          final firebaseExe = join(firebaseDir, "firebase.cmd");
          if (await _getVersion(firebaseExe)) {
            ctx.addBinary("firebase", firebaseDir, "firebase.cmd");
            return false; // Not missing!
          }
        }
      }
      // Try with system
      return await _getVersion("firebase");
    });
  }
}
