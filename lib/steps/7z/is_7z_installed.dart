import 'dart:io';

import 'package:installer/installer.dart';
import 'package:installer/steps/step.dart';
import 'package:path/path.dart';

class Is7zInstalled extends Step {
  Is7zInstalled() : super("See if 7z is missing");

  static const neededFiles = ["7zr.exe", "7za.exe", "7za.dll"];

  @override
  Future run() async {
    // Check Java in targetDir
    final dir = join(ctx.targetDir, "7z");
    final dirExists = await Directory(dir).exists();
    if (!dirExists) {
      return false;
    }
    final files = await dirList(dir);
    final filesBasenames = files.map((file) => basename(file));
    for (final file in neededFiles) {
      if (!filesBasenames.contains(file)) {
        return false;
      }
      final absFile = files.firstWhere((element) => element.endsWith(file));
      if (file.endsWith(".exe")) {
        final nameWithoutExtension =
            file.substring(0, file.length - ".exe".length);
        await ctx.addBinary(
            nameWithoutExtension, dirname(absFile), basename(absFile));
      }
    }
    return true;
  }
}
