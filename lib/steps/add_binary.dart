import 'dart:io';

import 'package:installer/context.dart';
import 'package:installer/log.dart';
import 'package:installer/run_installer.dart';
import 'package:installer/steps/step.dart';
import 'package:installer/utils.dart';
import 'package:path/path.dart';

abstract class EnvItem {
  add(String baseDir);
}

class Binary extends EnvItem {
  String cmd;
  String? win, mac, linux, all;
  Binary(this.cmd, {this.win, this.mac, this.linux, this.all});

  @override
  add(String baseDir) {
    late String? path;
    if (Platform.isWindows) {
      path = win ?? all;
    } else if (Platform.isMacOS) {
      path = mac ?? all;
    } else if (Platform.isLinux) {
      path = linux ?? all;
    } else {
      return error("Platform is not supported");
    }
    if (path == null) {
      return error("Path for $cmd is not specified on platform $os");
    }
    final file = basename(path);
    final subDir = dirname(path);
    final absDir = join(baseDir, subDir);
    ctx.addBinary(cmd, absDir, file);
    log.print("info: Added binary '$cmd' in '${join(absDir, file)}'.");
    return true;
  }
}

class EnvVariable extends EnvItem {
  String variable, value;
  EnvVariable(this.variable, [this.value = ""]);

  @override
  add(String baseDir) {
    ctx.addVariable(variable, join(baseDir, value));
  }
}

class AddToEnv extends SinglePriorStep {
  final String dir;
  final List<EnvItem> items;
  AddToEnv(this.dir, this.items) : super("AddToEnv");

  @override
  Future run() async {
    String baseDir;
    if (input == null) {
      baseDir = join(ctx.targetDir, dir);
    } else {
      baseDir = input.value;
    }
    for (final it in items) {
      final result = it.add(baseDir);
      if (result is InstallerError) {
        return result;
      }
    }
    return true;
  }
}
