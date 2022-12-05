import 'package:installer2/log.dart';
import 'package:installer2/steps/step.dart';
import 'package:installer2/utils.dart';

class GitNotInstalled extends Step<bool> {
  @override
  Future<bool> run() async {
    show("Determining if Git is installed");
    String? version = await getInstalledGitVersion();
    if (version != null) {
      log.print("Git: found version '$version'.");
    } else {
      log.print("Git: not found.");
    }
    return version == null;
  }
}
