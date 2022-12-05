import 'dart:io';

import 'package:html/parser.dart';
import 'package:installer2/context.dart';
import 'package:installer2/log.dart';
import 'package:installer2/semver.dart';
import 'package:installer2/steps/step.dart';
import 'package:installer2/steps/types.dart';
import 'package:http/http.dart' as http;

bool isSemVerGreaterThan(SemVer a, SemVer b) {
  return a.major > b.major || a.minor > b.minor || a.patch > b.patch;
}

bool isRecentLTS(SemVer v) {
  return v.major >= 16 && v.major % 2 == 0;
}

Future<SemVer> getLatestLTSVersion() async {
  final response = await http.get(Uri.parse("https://nodejs.org/dist/"));
  final document = parse(response.body);
  var latest = SemVer(0, 0, 0);
  for (final link in document.querySelectorAll("a")) {
    final name = link.text;
    if (name.startsWith("v") && name.endsWith("/")) {
      final version = SemVer.fromName(name.substring(1, name.length - 1));
      if (isRecentLTS(version) && version > latest) {
        latest = version;
      }
    }
  }
  if (latest.major == 0) {
    log.print("Node: no node versions found");
    throw "Node: no versions found";
  }
  return latest;
}

class NodeGetDownloadURL extends Step<URL> {
  @override
  Future<URL> run() async {
    show("Determining Node Download URL");
    log.print("Node: Determining latest LTS version");
    final version = await getLatestLTSVersion();
    log.print("Node: found version $version");

    String os =
        Platform.isMacOS ? "darwin" : (Platform.isLinux ? "linux" : "windows");
    String arch = ctx.getVariable("arch")!;
    if (arch == "x86_64") {
      arch = "x64";
    }
    String extension = Platform.isWindows ? ".zip" : ".tar.gz";
    final file = "node-$version-$os-$arch$extension";
    final url = "https://nodejs.org/dist/$version/$file";
    log.print("Node: Download URL is '$url'");
    return Future.value(URL(url));
  }
}
