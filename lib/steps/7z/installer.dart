import 'package:installer/steps/add_binary.dart';
import 'package:installer/steps/decompress.dart';
import 'package:installer/steps/download_file.dart';
import 'package:installer/steps/give_url.dart';
import 'package:installer/steps/move.dart';
import 'package:installer/steps/step.dart';

Step i7z() {
  return Chain("7z", [
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
  ]);
}
