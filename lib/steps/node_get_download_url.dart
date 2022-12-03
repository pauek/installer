import 'package:html/parser.dart';
import 'package:installer2/log.dart';
import 'package:installer2/steps/step.dart';
import 'package:installer2/steps/types.dart';
import 'package:http/http.dart' as http;

final semVerRegex = RegExp(r"^v(\d+)\.(\d+)\.(\d+).*");

class SemVer {
  late int major, minor, patch;

  SemVer(this.major, this.minor, this.patch);

  SemVer.fromName(String name) {
    final match = semVerRegex.firstMatch(name);
    if (match == null) {
      throw "Not a Semantic Version!";
    }
    major = int.parse(match.group(1)!);
    minor = int.parse(match.group(2)!);
    patch = int.parse(match.group(3)!);
  }

  @override
  String toString() => "v$major.$minor.$patch";
}

bool isSemVer(String name) {
  return name.startsWith("v") && name.endsWith("/");
}

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
    if (isSemVer(name)) {
      final version = SemVer.fromName(name);
      if (isRecentLTS(version) && isSemVerGreaterThan(version, latest)) {
        log.print("Found newer version: $version");
        latest = version;
      }
    }
  }
  if (latest.major == 0) {
    log.print("No node versions found");
    throw "No node versions found";
  }
  return latest;
}

class NodeGetDownloadURL extends Step<URL> {
  @override
  Future<URL> run() async {
    show("Determining Node Download URL");
    log.print("Determining Node latest LTS version");
    final version = await getLatestLTSVersion();
    log.print("Found version $version");

    // if (Platform.isMacOS || Platform.isLinux) {
    //   throw "MacOS and Linux download of Git not implemented yet";
    // }
    // log.print("Git Windows version URL at: '$gitForWindowsURL'");

    final nodeZipFile = "node-$version-win-x64.zip";
    final nodeDownloadURL = "https://nodejs.org/dist/$version/$nodeZipFile";
    log.print("Node download URL is: $nodeDownloadURL");
    show("Done${' ' * 60}");
    return Future.value(URL(nodeDownloadURL));
  }
}
