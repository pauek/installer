import 'dart:io';

import 'package:installer2/context.dart';
import 'package:installer2/log.dart';
import 'package:installer2/steps/step.dart';
import 'package:installer2/utils.dart';
import 'package:path/path.dart';

const flutterGithubRepo = "https://github.com/flutter/flutter.git";

class CloneGithubRepository extends Step<void> {
  final String dir, repoUrl;

  CloneGithubRepository(this.dir, this.repoUrl);

  @override
  Future<void> run() async {
    show("Cloning repository '$repoUrl'");

    // Check if repo is already there
    final targetDir = join(ctx.targetDir, dir);
    final gitOrigin = await getGitRemote(targetDir);
    if (gitOrigin != null && gitOrigin == repoUrl) {
      log.print("Git repo for '$dir' already present");
      return;
    }

    // Clone Repo
    log.print("Cloning GitHub repository $repoUrl.");
    final git = ctx.getBinary("git");
    final cloneResult = await Process.run(
      git,
      ["clone", flutterGithubRepo, dir],
      workingDirectory: ctx.targetDir,
    );
    if (cloneResult.exitCode != 0) {
      log.print("Git clone returned error ${cloneResult.exitCode}");
      final output = cloneResult.stderr.toString().trim();
      for (final line in output.split("\n")) {
        log.print(" >> $line");
      }
      show("ERROR (check .log file for details)");
    } else {
      log.print("Repo '$repoUrl' cloned ok.");
    }
  }
}
