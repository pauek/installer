import 'package:installer/context.dart';
import 'package:installer/log.dart';
import 'package:installer/steps/step.dart';
import 'package:installer/steps/types.dart';
import 'package:installer/utils.dart';
import 'package:path/path.dart';

class GitInstall extends Step {
  GitInstall() : super("Install git");

  @override
  Future run() async {
    if (input is! Dirname) {
      return error("GitInstall needs a Dirname as input");
    }
    final dirname = input;
    return withMessage("Registering git binary", () async {
      Filename gitExe = Filename(join(dirname.value, "cmd", "git.exe"));
      ctx.addBinary("git", join(dirname.value, "cmd"), "git.exe");
      log.print("info: Git installed at '${gitExe.value}'.");
      return gitExe;
    });
  }
}
