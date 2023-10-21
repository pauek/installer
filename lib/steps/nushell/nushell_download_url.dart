import 'dart:io';

import 'package:installer/installer.dart';
import 'package:installer/steps/step.dart';
import 'package:installer/steps/types.dart';

class GetNushellDownloadURL extends Step {
  GetNushellDownloadURL() : super("Get Nushell download URL");

  @override
  Future run() async {
    final nuVersion = await getLastTag('nushell', 'nushell');
    log.print("info: Nuversion found on GitHub: $nuVersion");

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
    log.print("info: Nushell is at '$url'.");
    return URL(url);
  }
}
