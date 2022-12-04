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
  Future<Dirname> run() async {
    show("Waiting to decompress...");
    final absFile = (await input as Filename).value;
    show("Decompressing '$absFile'... ");
    final absDir = join(ctx.targetDir, subDir);
    log.print("Decompressing '$absFile' into '$absDir'");
    await decompressFile(absFile, absDir);
    log.print("Decompression ok");
    show("Done${' ' * (30 + absFile.length)}");
    return Dirname(absDir);
  }
}
