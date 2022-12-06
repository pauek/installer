import 'package:installer2/context.dart';
import 'package:installer2/log.dart';
import 'package:installer2/steps/step.dart';
import 'package:installer2/steps/types.dart';
import 'package:path/path.dart';

class GitInstall extends Step<Filename> {
  @override
  Future<Filename> run() async {
    show("Registering git binary");
    final dirname = await input.run();
    Filename gitExe = Filename(join(dirname.value, "cmd", "git.exe"));
    ctx.addBinary("git", join(dirname.value, "cmd"), "git.exe");
    log.print("Git executable at '${gitExe.value}'");
    return gitExe;
  }
}
