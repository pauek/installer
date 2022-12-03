import 'package:installer2/context.dart';
import 'package:installer2/log.dart';
import 'package:installer2/steps/step.dart';
import 'package:installer2/steps/types.dart';
import 'package:installer2/utils.dart';
import 'package:path/path.dart';

class Decompress extends SinglePriorStep<Dirname, Filename> {
  String subDir;
  Decompress(this.subDir, Step<Filename> input) : super(input);

  @override
  Future<Dirname> run() async {
    show("Waiting to decompress...");
    final absPath = (await input).value;
    show("Decompressing '$absPath'... ");
    final absDir = join(ctx.targetDir, subDir);
    log.print("Decompressing '$absPath' into '$absDir'");
    await decompressFile(absPath, absDir);
    log.print("Decompression ok");
    show("Done${' ' * (30 + absPath.length)}");
    return Dirname(absDir);
  }
}
