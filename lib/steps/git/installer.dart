import 'package:installer/steps/add_binary.dart';
import 'package:installer/steps/decompress.dart';
import 'package:installer/steps/download_file.dart';
import 'package:installer/steps/git/git_get_download_url.dart';
import 'package:installer/steps/git/is_git_installed.dart';
import 'package:installer/steps/if.dart';
import 'package:installer/steps/not.dart';
import 'package:installer/steps/step.dart';

Step iGit() {
  return Chain("Git", [
    If(
      Not(IsGitInstalled()),
      then: Chain.noPrefix([
        GitGetDownloadURL(),
        DownloadFile(),
        Decompress(into: "git"),
        AddToEnv(dir: "git", items: [
          Binary("git", win: r"cmd\git.exe"),
        ])
      ]),
    ),
  ]);
}