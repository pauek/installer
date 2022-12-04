import 'package:console/console.dart';
import 'package:installer2/context.dart';
import 'package:installer2/log.dart';
import 'package:installer2/steps/step.dart';
import 'package:installer2/steps/types.dart';
import 'package:installer2/utils.dart';
import 'package:path/path.dart';

class FlutterCloneRepo extends Step<void> {
  FlutterCloneRepo({required Step ifInstallGit}) : super([ifInstallGit]);

  @override
  set pos(CursorPosition p) {
    super.pos = p;
    steps[0].pos = p;
  }

  @override
  Future<void> run() async {
    show("Cloning Flutter git repository");
    Filename gitExe = Filename("git");
    String? version = await getInstalledGitVersion();
    if (version != null) {
      log.print("Git: version found is '$version'.");
    } else {
      log.print("Git: not found. Installing.");
      final dirname = await steps[0].run();
      gitExe = Filename(join(dirname.value, "cmd", "git.exe"));
      ctx.addBinary("git", join(dirname.value, "cmd"), "git.exe");
    }
    log.print("Git executable at '${gitExe.value}'");
  }
}
