import 'package:installer2/context.dart';
import 'package:installer2/log.dart';
import 'package:installer2/steps/step.dart';
import 'package:installer2/steps/types.dart';
import 'package:installer2/utils.dart';
import 'package:path/path.dart';

class DownloadFile extends SinglePriorStep {
  String? forcedFilename;
  DownloadFile([this.forcedFilename]) : super("Download file");

  @override
  Future run() async {
    if (input is! URL) {
      return error("DownloadFile needs a URL as input");
    }
    final url = input;
    final urlPath = Uri.parse(url.value).path;
    final filename = forcedFilename ?? basename(urlPath);
    log.print("info: Downloading '$filename' from '${url.value}'.");
    final absFilename = join(ctx.downloadDir, filename);
    if (await downloadFile(url: url.value, path: absFilename)) {
      log.print("info: Downloaded '$absFilename'.");
    } else {
      log.print("ERROR: Error downloading file '${url.value}'.");
      return error("Error downloading '${url.value}'.");
    }
    return Filename(absFilename);
  }
}
