import 'dart:io';

import 'package:installer2/context.dart';
import 'package:installer2/log.dart';
import 'package:installer2/steps/step.dart';
import 'package:installer2/steps/types.dart';
import 'package:installer2/utils.dart';
import 'package:path/path.dart';

const flutterRepo = "https://github.com/flutter/flutter.git";

class CloneGithubRepo extends Step<Dirname?> {
  final String dir, repoUrl;
  final String? branch;

  CloneGithubRepo(this.dir, this.repoUrl, {this.branch});

  @override
  Future<Dirname?> run() async {
    return await withMessage(
      "Cloning repository '$repoUrl'",
      () async {
        // Check if repo is already there
        final targetDir = join(ctx.targetDir, dir);
        final gitOrigin = await getGitRemote(targetDir);
        if (gitOrigin != null && gitOrigin == repoUrl) {
          log.print("Git repo for '$dir' already present");
          return Dirname(targetDir);
        }

        // Clone Repo
        log.print("Cloning GitHub repository $repoUrl.");
        final git = ctx.getBinary("git");
        final cloneResult = await Process.run(
          git,
          [
            "clone",
            flutterRepo,
            dir,
            if (branch != null) ...["-b", branch!],
          ],
          workingDirectory: ctx.targetDir,
        );
        if (cloneResult.exitCode != 0) {
          log.print("Git clone returned error ${cloneResult.exitCode}");
          log.showOutput(cloneResult.stderr.toString().trim());
          // show("ERROR (check .log file for details)");
          return null;
        } else {
          log.print("Repo '$repoUrl' cloned ok.");
          return Dirname(targetDir);
        }
      },
    );
  }
}
