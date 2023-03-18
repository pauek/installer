import 'package:installer/context.dart';
import 'package:installer/log.dart';
import 'package:installer/steps/step.dart';
import 'package:installer/utils.dart';
import 'package:path/path.dart';

class GitRepositoryPresent extends Step {
  final String dir, repoUrl;
  GitRepositoryPresent(this.dir, this.repoUrl) : super("Repo $dir is missing");

  @override
  Future run() async {
    final flutterDir = join(ctx.targetDir, dir);
    final remote = await getGitRemote(flutterDir);
    final missing = remote == null || remote != repoUrl;
    if (missing) {
      log.print("info: Git repository '$repoUrl' missing at '$dir'.");
      return false;
    } else {
      log.print("info: Git repository '$repoUrl' found at '$dir'.");
      return true;
    }
  }
}
