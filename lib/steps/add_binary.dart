import 'dart:io';

import 'package:installer2/context.dart';
import 'package:installer2/log.dart';
import 'package:installer2/run_installer.dart';
import 'package:installer2/steps/step.dart';
import 'package:installer2/utils.dart';
import 'package:path/path.dart';

class Binary {
  String cmd;
  String? win, mac, linux, all;
  Binary(this.cmd, {this.win, this.mac, this.linux, this.all});
}

class AddBinaries extends SinglePriorStep {
  final String dir;
  final List<Binary> binaries;
  AddBinaries(this.dir, this.binaries);

  @override
  Future run() async {
    final result = await input.run();
    if (result is InstallerError) {
      return result;
    }
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
        return error("Platform is not supported");
      }
      // FIXME: Do this better!!
      if (b.cmd == "java") {
        ctx.addVariable("JAVA_HOME", baseDir);
      }
      if (path == null) {
        return error("Path for ${b.cmd} is not specified on platform $os");
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
