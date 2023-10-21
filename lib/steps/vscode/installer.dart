import 'package:installer/steps/add_binary.dart';
import 'package:installer/steps/decompress.dart';
import 'package:installer/steps/download_file.dart';
import 'package:installer/steps/give_url.dart';
import 'package:installer/steps/if.dart';
import 'package:installer/steps/not.dart';
import 'package:installer/steps/step.dart';
import 'package:installer/steps/vscode/is_vscode_installed.dart';

Step iVSCode() {
  return Chain("VSCode", [
    If(
      Not(IsVSCodeInstalled()),
      then: Chain.noPrefix([
        GiveURL(
          "https://code.visualstudio.com"
          "/sha/download?build=stable&os=win32-x64-archive",
        ),
        DownloadFile("vscode.zip"),
        Decompress(into: "vscode"),
        AddToEnv(dir: "vscode", items: [
          Binary("code", win: r"bin\code.cmd", all: "bin/code"),
        ]),
      ]),
    )
  ]);
}
