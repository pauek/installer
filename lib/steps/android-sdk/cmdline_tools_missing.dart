import 'dart:io';

import 'package:installer2/context.dart';
import 'package:installer2/log.dart';
import 'package:installer2/steps/step.dart';
import 'package:installer2/utils.dart';
import 'package:path/path.dart';

class CmdlineToolsMissing extends Step {
  static final _rVersion = RegExp(r"^(?<version>[\d\.]+)");

  Future<bool> _getVersion(String exe) async {
    final result = await Process.run(exe, ["--version"], runInShell: true);
    final match = _rVersion.firstMatch(result.stdout.trim());
    String? version = match?.namedGroup("version");
    if (version != null) {
      log.print("info: '${basename(exe)}' found, version '$version'.");
    }
    return version == null;
  }

  @override
  Future run() async {
    final result = await waitForInput();
    if (result is InstallerError) {
      return result;
    }
    return withMessage("Determining if cmdline-tools are installed", () async {
      final androidTargetDir = join(ctx.targetDir, "android-sdk");
      final cmdlineToolsBinDir = join(
        androidTargetDir,
        "cmdline-tools/latest/bin",
      );
      if (await Directory(cmdlineToolsBinDir).exists()) {
        final sdkmanagerExe = join(cmdlineToolsBinDir, "sdkmanager.bat");
        if (await _getVersion(sdkmanagerExe)) {
          ctx.addBinary("sdkmanager", cmdlineToolsBinDir, "sdkmanager.bat");
          return false; // Not missing!
        }
      }
      // Try with system
      return await _getVersion("sdkmanager");
    });
  }
}
