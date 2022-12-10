import 'dart:io';

import 'package:installer2/context.dart';
import 'package:installer2/log.dart';
import 'package:installer2/steps/step.dart';
import 'package:installer2/utils.dart';
import 'package:path/path.dart';

class CmdlineToolsMissing extends Step {
  static final _rVersion = RegExp(r"^(?<version>[\d\.]+)");

  Future<String?> _getVersion(String exe) async {
    final result = await Process.run(exe, ["--version"], runInShell: true);
    final match = _rVersion.firstMatch(result.stdout.trim());
    String? version = match?.namedGroup("version");
    if (version != null) {
      log.print("info: '${basename(exe)}' found, version '$version'.");
    }
    return version;
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
        final version = await _getVersion(sdkmanagerExe);
        if (version != null) {
          ctx.addBinary("sdkmanager", cmdlineToolsBinDir, "sdkmanager.bat");
          return false; // Not missing!
        }
      }
      // Try with system
      final systemVersion = await _getVersion("sdkmanager");
      if (systemVersion == null) {
        log.print("info: cmdline-tools missing in system");
      }
      return systemVersion == null;
    });
  }
}
