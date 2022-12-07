import 'dart:io';

import 'package:installer2/log.dart';
import 'package:installer2/semver.dart';
import 'package:installer2/steps/step.dart';

class VersionInstalled extends Step<SemVer?> {
  final String cmd;
  final RegExp versionRegexp;
  VersionInstalled(this.cmd, this.versionRegexp);

  @override
  Future<SemVer?> run() async {
    return await withMessage(
      "Determining if $cmd is installed",
      () async {
        final result = await Process.run(cmd, ["--version"], runInShell: true);
        final output = result.stdout.trim();
        final match = versionRegexp.firstMatch(output);
        String? version = match?.namedGroup("version");
        if (version != null) {
          log.print("$cmd: found version '$version'.");
        } else {
          log.print("$cmd: not found.");
        }
        return version != null ? SemVer.fromName(version) : null;
      },
    );
  }
}
