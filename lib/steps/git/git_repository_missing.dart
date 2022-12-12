import 'package:installer2/context.dart';
import 'package:installer2/log.dart';
import 'package:installer2/steps/step.dart';
import 'package:installer2/utils.dart';
import 'package:path/path.dart';

class GitRepositoryMissing extends Step {
  final String dir, repoUrl;
  GitRepositoryMissing(this.dir, this.repoUrl) : super("Repo $dir is missing");

  @override
  Future run() async {
    final flutterDir = join(ctx.targetDir, dir);
    final remote = await getGitRemote(flutterDir);
    final missing = remote == null || remote != repoUrl;
    if (missing) {
      log.print("info: Git repository '$repoUrl' missing at '$dir'.");
      return true;
    } else {
      log.print("info: Git repository '$repoUrl' found at '$dir'.");
      return false;
    }
  }
}
