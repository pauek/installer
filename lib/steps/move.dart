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

    // To move the file, we first copy it and then erase the origial
    // in case the paths are in different disks (or units in Windows)
    // TODO: Check if the unit/filesystem is the same?

    // 1) Copy the file
    final File file;
    try {
      file = await File(absPath).copy(newAbsPath);
      if (file.absolute.path != newAbsPath) {
        return installerError("Something went wrong copying file $filename");
      }
    } catch (e) {
      return installerError("Something went wrong copying file $filename");
    }

    // 2) Delete the file
    try {
      await File(absPath).delete();
    } catch (e) {
      return installerError("Something went wrong deleting file $absPath");
    }

    log.print("info: Moved file to '${file.absolute.path}'");
    return Dirname(dirname(file.absolute.path));
  }
}
