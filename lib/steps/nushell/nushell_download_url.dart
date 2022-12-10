import 'dart:io';

import 'package:installer2/log.dart';
import 'package:installer2/run_installer.dart';
import 'package:installer2/steps/step.dart';
import 'package:installer2/steps/types.dart';
import 'package:installer2/utils.dart';

const nuVersion = "0.72.0";

class GetNushellDownloadURL extends Step {
  @override
  Future run() async {
    final result = await waitForInput();
    if (result is InstallerError) {
      return result;
    }
    return withMessage("Get nu download URL", () async {
      late String nuZip;
      if (Platform.isWindows) {
        nuZip = "nu-$nuVersion-x86_64-pc-windows-msvc.zip";
      } else if (Platform.isMacOS) {
        final nuarch = (arch == "arm64" ? "aarch64" : "x86_64");
        nuZip = "nu-$nuVersion-$nuarch-apple-darwin.tar.gz";
      } else if (Platform.isLinux) {
        nuZip = "nu-$nuVersion-x86_64-unknown-linux-musl.tar.gz";
      }
      final url = "https://github.com/nushell/nushell/releases/download/"
          "$nuVersion/$nuZip";
      log.print("Nushell: URL is '$url'");
      return URL(url);
    });
  }
}
