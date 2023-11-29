import 'dart:io';

import 'package:installer/installer.dart';
import 'package:installer/steps/step.dart';
import 'package:installer/steps/types.dart';
import 'package:path/path.dart';

class DownloadFile extends SinglePriorStep {
  String? forcedFilename;
  DownloadFile([this.forcedFilename]) : super("Download file");

  @override
  Future run() async {
    if (input is! URL) {
      return installerError("DownloadFile needs a URL as input");
    }
    final url = input;
    final urlPath = Uri.parse(url.value).path;
    final filename = forcedFilename ?? basename(urlPath);
    log.print("info: Downloading '$filename' from '${url.value}'.");
    final absFilename = join(ctx.downloadDir, filename);

    //
    // If file already exists, return it
    // FIXME: If anyone changes the file, then it can be a mess
    // - All installers after the wrong filename will fail.
    // - We should be taking a hash of the file and keeping it
    //   so that we can make sure the file is the same and has not been
    //   changed.
    // - If the file doesn't match, we download it and overwrite it.
    //
    if (File(absFilename).existsSync()) {
      return Filename(absFilename);
    }
    if (await downloadFile(url: url.value, path: absFilename)) {
      log.print("info: Downloaded '$absFilename'.");
    } else {
      log.print("ERROR: Error downloading file '${url.value}'.");
      return installerError("Error downloading '${url.value}'.");
    }
    return Filename(absFilename);
  }
}
