import 'package:installer/installer/context.dart';
import 'package:installer/steps/add_binary.dart';
import 'package:installer/steps/clone_github_repo.dart';
import 'package:installer/steps/decompress.dart';
import 'package:installer/steps/download_file.dart';
import 'package:installer/steps/flutter/flutter_get_download_url.dart';
import 'package:installer/steps/git/git_repository_present.dart';
import 'package:installer/steps/if.dart';
import 'package:installer/steps/not.dart';
import 'package:installer/steps/run_command.dart';
import 'package:installer/steps/step.dart';
import 'package:path/path.dart';

Step iFlutter() {
  return Chain("Flutter", [
    If(
      Not(GitRepositoryPresent("flutter", flutterRepo)),
      then: Chain.noPrefix([
        FlutterGetDownloadURL(),
        DownloadFile(),
        // UGLY: The Flutter Zip file has a "flutter" directory inside, so
        // we don't want to have "flutter/flutter" duplicated, that is why
        // the into here is ""
        Decompress(into: "", eraseDirFirst: false),
      ]),
    ),
    // FIXME: In windows this complains that the directory is no absolute??
    // AddToEnv(dir: "flutter", items: [
    //   Binary("flutter", win: r"bin\flutter.bat", all: "bin/flutter"),
    //   Binary("dart", win: r"bin\dart.bat", all: "bin/dart"),
    // ]),
  ]);
}

Step iFlutterFire() {
  return Chain("FlutterFire", [
    RunCommand(
      "dart",
      args: ["pub", "global", "activate", "flutterfire_cli"],
      envPath: [
        () => dirname(ctx.getBinary("git")),
      ],
    ),
  ]);
}
