import 'dart:io';

import 'package:installer2/context.dart';
import 'package:installer2/log.dart';
import 'package:installer2/steps/step.dart';
import 'package:installer2/utils.dart';
import 'package:path/path.dart';

class IsFirebaseCliInstalled extends Step {
  IsFirebaseCliInstalled() : super("See if firebase CLI is missing");

  static final _rVersion = RegExp(r"^(?<version>[\d\.]+)");

  Future<String?> _getVersion(String exe) async {
    final result = await Process.run(exe, ["--version"], runInShell: true);
    final match = _rVersion.firstMatch(result.stdout.trim());
    String? version = match?.namedGroup("version");
    if (version != null) {
      log.print("info: 'firebase' found, version '$version'.");
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
        final firebaseExe = join(nodeDir, "firebase.cmd");
        final version = await _getVersion(firebaseExe);
        if (version != null) {
          ctx.addBinary("firebase", nodeDir, "firebase.cmd");
          return true; // installed!
        }
      }
    }
    log.print("info: firebase not found in system.");
    return false;
  }
}
