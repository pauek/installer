import 'package:installer2/run_installer.dart';

import 'flutter_installer.dart';

final rJavaVersion = RegExp(r"^(?:java|openjdk) (?<version>[\d\.]+)");
final rGitVersion = RegExp(r"^git version (?<version>[\w\.]+)$");

void main(List<String> arguments) {
  runInstaller(
    install7z,
  );
}
