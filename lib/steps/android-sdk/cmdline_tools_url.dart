import 'dart:io';

import 'package:html/parser.dart';
import 'package:http/http.dart' as http;
import 'package:installer2/log.dart';
import 'package:installer2/steps/step.dart';
import 'package:installer2/steps/types.dart';
import 'package:path/path.dart';

String getOS() {
  if (Platform.isWindows) {
    return "win";
  } else if (Platform.isMacOS) {
    return "mac";
  } else if (Platform.isLinux) {
    return "linux";
  } else {
    throw "Platform not supported";
  }
}

class GetAndroidCmdlineToolsURL extends Step<URL> {
  @override
  Future<URL> run() async {
    show("Detecting latest cmdline-tools version");
    final response = await http.get(
      Uri.parse("https://developer.android.com/studio"),
    );
    final os = getOS();
    final document = parse(response.body);
    final button = document.querySelector(
      'button[data-modal-dialog-id="sdk_${os}_download"]',
    );
    if (button == null) {
      throw "Android Studio page format has changed!";
    }
    final filename = button.text;
    final path = join("/android/repository/", filename);
    final url = "https://dl.google.com$path";
    log.print("Android: cmdline-tools URL is '$url'");
    return URL(url);
  }
}
