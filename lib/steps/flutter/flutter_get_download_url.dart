import 'dart:io';

import 'package:html/parser.dart';
import 'package:http/http.dart' as http;
import 'package:installer/installer.dart';
import 'package:installer/steps/step.dart';
import 'package:installer/steps/types.dart';

Future<String?> getLatestFlutterUrl() async {
  if (!Platform.isWindows) {
    return installerError(
      "This downloader does not work on platforms other than Windows",
    );
  }

  // Get the latest release from GitHub's tag page
  // If I use GitHub's API I have to put an API_KEY
  final response = await http.get(
    Uri.parse("https://github.com/flutter/flutter/tags"),
  );
  final document = parse(response.body);
  final anchors = document.querySelectorAll(
    'a[href^="/flutter/flutter/releases/tag"]',
  );
  if (anchors.isEmpty) {
    return installerError("Github flutter tags page has changed format");
  }

  // Get the first tag which doesn't have "pre" in the name
  String? getLatestVersion() {
    for (final a in anchors) {
      if (!a.text.endsWith(".pre")) return a.text;
    }
    return null;
  }

  final version = getLatestVersion();
  if (version == null) {
    log.print("error: Didn't find a version without .pre in GitHub tags");
    return null;
  }
  log.print("info: Latest Flutter version is $version");

  // This links was obtained from the page: https://docs.flutter.dev/get-started/install/windows
  // The installer depends quite a bit on it but seems safe
  return "https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_$version-stable.zip";
}

class FlutterGetDownloadURL extends Step {
  FlutterGetDownloadURL() : super("Get Flutter download URL");

  @override
  Future run() async {
    final url = await getLatestFlutterUrl();
    if (url == null) {
      return installerError("Could not determine Flutter download URL");
    }
    log.print("info: Flutter download URL is '$url'.");
    return Future.value(URL(url));
  }
}
