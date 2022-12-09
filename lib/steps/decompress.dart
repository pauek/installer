import 'package:installer2/context.dart';
import 'package:installer2/log.dart';
import 'package:installer2/steps/step.dart';
import 'package:installer2/steps/types.dart';
import 'package:installer2/utils.dart';
import 'package:path/path.dart';

class Decompress extends SinglePriorStep {
  String subDir;
  Decompress({required String into}) : subDir = into;

  @override
  Future run() async {
    final result = await input.run();
    if (result is InstallerError) {
      return result;
    }
    if (result is! Filename) {
      return InstallerError("Decompress: Expected a Filename as input");
    }
    final absFile = result.value;
    return withMessage<Dirname>(
      "Decompressing '$absFile'",
      () async {
        var absDir = join(ctx.targetDir, subDir);
        log.print("Decompressing '$absFile' into '$absDir'");
        await decompress(absFile, absDir);
        log.print("Decompression ok");

        // If there is only one folder inside, return that!
        final dirList = await dirListSubdirectories(absDir);
        if (dirList.dirs.length == 1 && dirList.files.isEmpty) {
          absDir = dirList.dirs[0];
          log.print("Decompress result changed to '$absDir'");
        }
        return Dirname(absDir);
      },
    );
  }
}
