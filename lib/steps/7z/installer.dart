import 'package:installer/steps.dart';
import 'package:installer/steps/7z/is_7z_installed.dart';

Step i7z() {
  return Chain("7z", [
    If(
      Not(Is7zInstalled()),
      then: Chain.noPrefix([
        GiveURL("https://www.7-zip.org/a/7zr.exe"),
        DownloadFile(),
        Move(into: "7z"),
        AddToEnv(dir: "7z", items: [
          Binary("7zr", win: "7zr.exe"),
        ]),
        GiveURL("https://www.7-zip.org/a/7z2301-extra.7z"),
        DownloadFile(),
        Decompress(into: "7z", eraseDirFirst: false),
        AddToEnv(dir: "7z", items: [
          Binary("7za", win: "7za.exe"),
        ]),
      ]),
    )
  ]);
}
