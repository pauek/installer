import 'dart:io';

import 'package:html/parser.dart';
import 'package:http/http.dart' as http;
import 'package:installer/installer.dart';
import 'package:installer/steps/step.dart';
import 'package:installer/steps/types.dart';

Future<String> getLatestFlutterUrl() async {
  if (!Platform.isWindows) {
    return installerError(
      "This downloader does not work on platforms other than Windows",
    );
  }
  final response = await http.get(
    Uri.parse("https://docs.flutter.dev/get-started/install/windows"),
  );
  final document = parse(response.body);
  final anchor = document.querySelector(
    '#downloads-windows-stable',
  );
  if (anchor == null) {
    return installerError("Flutter get started page has changed format");
  }
  final textContent = anchor.text.trim();
  return "https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/${textContent}";
}

class FlutterGetDownloadURL extends Step {
  FlutterGetDownloadURL() : super("Get Flutter download URL");

  @override
  Future run() async {
    final url = await getLatestFlutterUrl();
    log.print("info: Flutter download URL is '$url'.");
    return Future.value(URL(url));
  }
}
