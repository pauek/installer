import 'dart:io';

import 'package:html/parser.dart';
import 'package:http/http.dart' as http;
import 'package:installer2/log.dart';
import 'package:installer2/run_installer.dart';
import 'package:installer2/steps/step.dart';
import 'package:installer2/steps/types.dart';
import 'package:installer2/utils.dart';

const targetJdkVersion = 19;

Future<bool> isOurPlatformDownload(String url) async {
  if (Platform.isWindows) {
    return url.endsWith(".zip") && url.contains("windows");
  } else if (Platform.isMacOS) {
    return url.endsWith(".tar.gz") &&
        url.contains(arch == "arm64" ? "macos-aarch64" : "macos-x64");
  } else if (Platform.isLinux) {
    return url.endsWith(".tar.gz") &&
        url.contains(arch == "x86_64" ? "linux-x64" : "linux-aarch64");
  } else {
    return error("Platform not supported");
  }
}

Future<String> getLatestJdkUrl() async {
  final response = await http.get(
    Uri.parse("https://jdk.java.net/$targetJdkVersion/"),
  );
  final document = parse(response.body);
  final buildsTable = document.querySelector("table.builds");
  if (buildsTable == null) {
    return error("jdk.java.net has changed format");
  }
  final anchorElems = buildsTable.getElementsByTagName("a");
  if (anchorElems.isEmpty) {
    return error("jdk.java.net has changed format");
  }
  for (final a in anchorElems) {
    final href = a.attributes['href'];
    if (href == null) {
      return error("jdk.java.net has changed format");
    }
    if (await isOurPlatformDownload(href)) {
      return href;
    }
  }
  return error("Didn't find JDK download link for $arch");
}

class JavaGetDownloadURL extends Step {
  @override
  Future run() async {
    final result = await waitForInput();
    if (result is InstallerError) {
      return result;
    }
    return withMessage(
      "Determining Java Download URL",
      () async {
        final url = await getLatestJdkUrl();
        log.print("Java: download url is '$url'");
        return Future.value(URL(url));
      },
    );
  }
}
