import 'package:installer2/context.dart';
import 'package:installer2/log.dart';
import 'package:installer2/steps/step.dart';
import 'package:installer2/steps/types.dart';
import 'package:path/path.dart';

class Binary {
  String cmd;
  dynamic relativePath;
  Binary(this.cmd, this.relativePath);
}

class AddBinaries extends SinglePriorStep<bool, Dirname?> {
  final String dir;
  final List<Binary> binaries;
  AddBinaries(this.dir, this.binaries);

  @override
  Future<bool> run() async {
    final result = await input;
    String baseDir;
    if (result == null) {
      baseDir = join(ctx.targetDir, dir);
    } else {
      baseDir = result.value;
    }
    final os = ctx.getVariable("os");
    for (final b in binaries) {
      late String file, subDir;
      if (b.relativePath is Map<String, String>) {
        final relPath = b.relativePath[os] ?? b.relativePath["default"];
        file = basename(relPath);
        subDir = dirname(relPath);
      } else if (b.relativePath is String) {
        file = basename(b.relativePath);
        subDir = dirname(b.relativePath);
      }
      final absDir = join(baseDir, subDir);
      ctx.addBinary(b.cmd, absDir, file);
      log.print("Added binary '${b.cmd}' in '$absDir/$file'");
    }
    return true;
  }
}
