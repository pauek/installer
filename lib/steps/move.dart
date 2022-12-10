import 'dart:io';

import 'package:installer2/context.dart';
import 'package:installer2/steps/step.dart';
import 'package:installer2/steps/types.dart';
import 'package:installer2/utils.dart';
import 'package:path/path.dart';

class Move extends SinglePriorStep {
  final String into;
  final String? forcedFilename;
  Move({
    required this.into,
    this.forcedFilename,
  });

  @override
  Future run() async {
    final result = await waitForInput();
    if (result is InstallerError) {
      return result;
    }
    if (result is! Filename) {
      return error("Move: Expected Filename as input");
    }
    final absPath = result.value;
    final filename = forcedFilename ?? basename(absPath);
    return withMessage("Moving $filename", () async {
      final newAbsPath = join(ctx.targetDir, into, filename);
      await ensureDir(dirname(newAbsPath));
      final file = await File(absPath).rename(newAbsPath);
      if (file.absolute.path != newAbsPath) {
        return error("Something went wrong moving file $filename");
      }
      return Dirname(dirname(file.absolute.path));
    });
  }
}
