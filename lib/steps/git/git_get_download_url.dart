import 'package:installer2/log.dart';
import 'package:installer2/steps/step.dart';
import 'package:installer2/steps/types.dart';

const version = "2.38.1";
const gitForWindowsURL = "https://github.com"
    "/git-for-windows/git/releases/download/"
    "v$version.windows.1/MinGit-$version-64-bit.zip";

class GitGetDownloadURL extends Step<URL> {
  @override
  Future<URL> run() async {
    show("Getting git download URL");
    // if (Platform.isMacOS || Platform.isLinux) {
    //   throw "MacOS and Linux download of Git not implemented yet";
    // }
    log.print("Git: Windows version URL at '$gitForWindowsURL'");
    return Future.value(URL(gitForWindowsURL));
  }
}
