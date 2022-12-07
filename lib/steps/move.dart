import 'dart:io';

import 'package:installer2/context.dart';
import 'package:installer2/steps/step.dart';
import 'package:installer2/steps/types.dart';
import 'package:installer2/utils.dart';
import 'package:path/path.dart';

class Move extends SinglePriorStep<Dirname, Filename> {
  final String into;
  final String? forcedFilename;
  Move({
    required this.into,
    this.forcedFilename,
  });

  @override
  Future<Dirname> run() async {
    final absPath = ((await input.run()) as Filename).value;
    final filename = forcedFilename ?? basename(absPath);
    return await withMessage("Moving $filename", () async {
      final newAbsPath = join(ctx.targetDir, into, filename);
      await ensureDir(dirname(newAbsPath));
      final file = await File(absPath).rename(newAbsPath);
      if (file.absolute.path != newAbsPath) {
        throw "Something went wrong moving file $filename";
      }
      return Dirname(dirname(file.absolute.path));
    });
  }
}
