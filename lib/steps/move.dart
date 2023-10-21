import 'dart:io';

import 'package:installer/installer.dart';
import 'package:installer/steps/step.dart';
import 'package:installer/steps/types.dart';
import 'package:path/path.dart';

class Move extends SinglePriorStep {
  final String into;
  final String? forcedFilename;
  Move({
    required this.into,
    this.forcedFilename,
  }) : super("Move file into $into");

  @override
  Future run() async {
    if (input is! Filename) {
      return installerError("Move: Expected Filename as input");
    }
    final absPath = input.value;
    final filename = forcedFilename ?? basename(absPath);
    final newAbsPath = join(ctx.targetDir, into, filename);
    await ensureDir(dirname(newAbsPath));

    final file = await File(absPath).rename(newAbsPath);
    if (file.absolute.path != newAbsPath) {
      return installerError("Something went wrong moving file $filename");
    }
    log.print("info: Moved file to '${file.absolute.path}'");
    return Dirname(dirname(file.absolute.path));
  }
}
