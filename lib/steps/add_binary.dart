import 'dart:io';

import 'package:installer2/context.dart';
import 'package:installer2/log.dart';
import 'package:installer2/steps/step.dart';
import 'package:installer2/steps/types.dart';
import 'package:path/path.dart';

class Binary {
  String cmd;
  String? win, mac, linux, all;
  Binary(this.cmd, {this.win, this.mac, this.linux, this.all});
}

class AddBinaries extends SinglePriorStep<bool, Dirname?> {
  final String dir;
  final List<Binary> binaries;
  AddBinaries(this.dir, this.binaries);

  @override
  Future<bool> run() async {
    final result = await input.run();
    String baseDir;
    if (result == null) {
      baseDir = join(ctx.targetDir, dir);
    } else {
      baseDir = result.value;
    }
    for (final b in binaries) {
      late String? path;
      if (Platform.isWindows) {
        path = b.win ?? b.all;
      } else if (Platform.isMacOS) {
        path = b.mac ?? b.all;
      } else if (Platform.isLinux) {
        path = b.linux ?? b.all;
      } else {
        throw "Platform is not supported";
      }
      if (path == null) {
        final os = ctx.getVariable("os");
        throw "Path for ${b.cmd} is not specified on platform $os";
      }
      final file = basename(path);
      final subDir = dirname(path);
      final absDir = join(baseDir, subDir);
      ctx.addBinary(b.cmd, absDir, file);
      log.print("Added binary '${b.cmd}' in '${join(absDir, file)}'");
    }
    return true;
  }
}
