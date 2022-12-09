import 'package:installer2/context.dart';
import 'package:installer2/log.dart';
import 'package:installer2/steps/step.dart';
import 'package:installer2/steps/types.dart';
import 'package:installer2/utils.dart';
import 'package:path/path.dart';

class DownloadFile extends SinglePriorStep {
  String? forcedFilename;
  DownloadFile([this.forcedFilename]);

  @override
  Future run() async {
    final url = await input.run();
    final urlPath = Uri.parse(url.value).path;
    final filename = forcedFilename ?? basename(urlPath);
    return withMessage(
      "Downloading $filename",
      () async {
        log.print("Downloading '$filename' from '${url.value}'");
        final absFilename = join(ctx.downloadDir, filename);
        if (await downloadFile(url: url.value, path: absFilename)) {
          log.print("Downloaded successfully at '$absFilename'");
        } else {
          log.print("Error downloading file '${url.value}'");
          return error("Error downloading '${url.value}'");
        }
        return Filename(absFilename);
      },
    );
  }
}
