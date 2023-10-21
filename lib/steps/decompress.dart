import 'package:installer/installer.dart';
import 'package:installer/steps.dart';
import 'package:path/path.dart';

class Decompress extends SinglePriorStep {
  String subDir;
  bool eraseDirFirst;
  Decompress({required String into, this.eraseDirFirst = true})
      : subDir = into,
        super("Decompress into $into");

  @override
  Future run() async {
    if (input is! Filename) {
      return installerError("Decompress: Expected a Filename as input");
    }
    final absFile = input.value;
    var absDir = join(ctx.targetDir, subDir);

    log.print("info: Decompressing '$absFile' into '$absDir'.");
    final result = await decompress(absFile, absDir, eraseDirFirst: eraseDirFirst);
    if (result is InstallerError) {
      return result;
    }
    log.print("info: Decompression of '${basename(absFile)}' ok.");

    // If there is only one folder inside, return that!
    final dirList = await dirListSubdirectories(absDir);
    if (dirList.dirs.length == 1 && dirList.files.isEmpty) {
      absDir = dirList.dirs[0];
      log.print("info: Decompress result changed to '$absDir'.");
    }
    return Dirname(absDir);
  }
}
