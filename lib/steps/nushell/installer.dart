import 'package:installer/steps/add_binary.dart';
import 'package:installer/steps/decompress.dart';
import 'package:installer/steps/download_file.dart';
import 'package:installer/steps/if.dart';
import 'package:installer/steps/not.dart';
import 'package:installer/steps/nushell/is_nushell_installed.dart';
import 'package:installer/steps/nushell/nushell_download_url.dart';
import 'package:installer/steps/step.dart';

Step iNushell() {
  return Chain("Nushell", [
    If(
      Not(IsNushellInstalled()),
      then: Chain.noPrefix([
        GetNushellDownloadURL(),
        DownloadFile(),
        Decompress(into: "nu"),
        AddToEnv(dir: "nu", items: [
          Binary("nu", win: "nu.exe", all: "nu"),
        ])
      ]),
    )
  ]);
}
