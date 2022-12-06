import 'package:installer2/context.dart';
import 'package:installer2/log.dart';
import 'package:installer2/steps/step.dart';
import 'package:installer2/steps/types.dart';
import 'package:path/path.dart';

class GitInstall extends Step<Filename> {
  @override
  Future<Filename> run() async {
    return await withMessage(
      "Registering git binary",
      () async {
        final dirname = await input.run();
        Filename gitExe = Filename(join(dirname.value, "cmd", "git.exe"));
        ctx.addBinary("git", join(dirname.value, "cmd"), "git.exe");
        log.print("Git executable at '${gitExe.value}'");
        return gitExe;
      },
    );
  }
}
