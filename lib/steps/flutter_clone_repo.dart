import 'package:installer2/context.dart';
import 'package:installer2/log.dart';
import 'package:installer2/steps/step.dart';
import 'package:installer2/steps/types.dart';
import 'package:installer2/utils.dart';
import 'package:path/path.dart';

class FlutterCloneRepo extends SinglePriorStep<void, Dirname> {
  final Step<Dirname> installGit;
  FlutterCloneRepo({
    required this.installGit,
  }) : super(installGit);

  @override
  Future<void> run() async {
    show("Cloning Flutter git repository");
    Filename gitExe = Filename("git");
    if (!(await isGitInstalled())) {
      log.print("Git was not found installed, installing.");
      final dirname = await input;
      gitExe = Filename(join(dirname.value, "cmd", "git.exe"));
      ctx.addBinary("git", join(dirname.value, "cmd"), "git.exe");
    }
    log.print("Git executable at '${gitExe.value}'");
  }
}
