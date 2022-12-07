import 'package:installer2/run_installer.dart';
import 'package:installer2/steps/step.dart';
import 'package:installer2/steps/version_installed.dart';

final rJavaVersion = RegExp(r"^(?:java|openjdk) (?<version>[\d\.]+)");
final rGitVersion = RegExp(r"^git version (?<version>[\d\.]+)$");

void main(List<String> arguments) {
  runInstaller(
    Parallel([
      VersionInstalled("java", rJavaVersion),
      VersionInstalled("git", rGitVersion),
    ]),
  );
}
