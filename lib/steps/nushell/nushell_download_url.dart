import 'dart:io';

import 'package:installer2/context.dart';
import 'package:installer2/log.dart';
import 'package:installer2/steps/step.dart';
import 'package:installer2/steps/types.dart';

const nuVersion = "0.72.0";

class GetNushellDownloadURL extends Step<URL> {
  @override
  Future<URL> run() async {
    return await withMessage(
      "Get nu download URL",
      () async {
        late String nuZip;
        final arch = ctx.getVariable("arch");
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
      },
    );
  }
}
