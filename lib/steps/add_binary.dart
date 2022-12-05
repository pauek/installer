import 'package:installer2/context.dart';
import 'package:installer2/log.dart';
import 'package:installer2/steps/step.dart';
import 'package:path/path.dart';

class Binary {
  String cmd, relativePath;
  Binary(this.cmd, this.relativePath);
}

class AddBinaries extends SinglePriorStep<bool, dynamic> {
  final String dir;
  final List<Binary> binaries;
  AddBinaries(this.dir, this.binaries);

  @override
  Future<bool> run() async {
    await input;
    for (final b in binaries) {
      final file = basename(b.relativePath);
      final subDir = dirname(b.relativePath);
      final absDir = join(ctx.targetDir, dir);
      ctx.addBinary(b.cmd, join(absDir, subDir), file);
      log.print("Added binary '${b.cmd}' in '$absDir/$file'");
    }
    return true;
  }
}
