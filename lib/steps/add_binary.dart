import 'dart:io';

import 'package:installer/installer.dart';
import 'package:installer/steps/step.dart';
import 'package:path/path.dart';

abstract class EnvItem {
  Future add(String baseDir);
}

class Binary extends EnvItem {
  String cmd;
  String? win, mac, linux, all;
  Binary(this.cmd, {this.win, this.mac, this.linux, this.all});

  @override
  Future add(String baseDir) async {
    late String? path;
    if (Platform.isWindows) {
      path = win ?? all;
    } else if (Platform.isMacOS) {
      path = mac ?? all;
    } else if (Platform.isLinux) {
      path = linux ?? all;
    } else {
      return installerError("Platform is not supported");
    }
    if (path == null) {
      return installerError("Path for $cmd is not specified on platform $os");
    }
    final file = basename(path);
    final subDir = dirname(path);
    final absDir = normalize(join(baseDir, subDir));
    await ctx.addBinary(cmd, absDir, file);
    return true;
  }
}

class EnvVariable extends EnvItem {
  String variable, value;
  EnvVariable(this.variable, [this.value = ""]);

  @override
  Future add(String baseDir) async {
    ctx.addVariable(variable, join(baseDir, value));
  }
}

class AddToEnv extends SinglePriorStep {
  final String dir;
  final List<EnvItem> items;
  AddToEnv({
    required this.dir,
    required this.items,
  }) : super("AddToEnv");

  @override
  Future run() async {
    String baseDir;
    if (input == null) {
      baseDir = join(ctx.targetDir, dir);
    } else {
      baseDir = input.value;
    }
    for (final it in items) {
      final result = await it.add(baseDir);
      if (result is InstallerError) {
        return result;
      }
    }
    return true;
  }
}
