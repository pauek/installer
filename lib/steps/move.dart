import 'dart:io';

import 'package:installer2/context.dart';
import 'package:installer2/steps/step.dart';
import 'package:installer2/steps/types.dart';
import 'package:path/path.dart';

class Move extends SinglePriorStep<String, Filename> {
  final String into;
  Move({required this.into});

  @override
  Future<String> run() async {
    final absPath = ((await input.run()) as Filename).value;
    final filename = basename(absPath);
    return await withMessage("Moving $filename", () async {
      final newAbsPath = join(ctx.targetDir, into, filename);
      final file = await File(absPath).rename(newAbsPath);
      if (file.absolute.path != newAbsPath) {
        throw "Something went wrong moving file $filename";
      }
      return file.absolute.path;
    });
  }
}
