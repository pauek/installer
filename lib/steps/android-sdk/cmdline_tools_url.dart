import 'package:html/parser.dart';
import 'package:http/http.dart' as http;
import 'package:installer/steps/step.dart';
import 'package:installer/steps/types.dart';
import 'package:installer/installer.dart';
import 'package:path/path.dart';

class GetAndroidCmdlineToolsURL extends Step {
  GetAndroidCmdlineToolsURL() : super("Get Android cmdline-tools URL");

  @override
  Future run() async {
    final response = await http.get(
      Uri.parse("https://developer.android.com/studio"),
    );
    final os = getOS();
    final document = parse(response.body);
    final button = document.querySelector(
      'button[data-modal-dialog-id="sdk_${os}_download"]',
    );
    if (button == null) {
      return installerError("Android Studio page format has changed!");
    }
    final filename = button.text;
    final path = join("/android/repository/", filename);
    final url = "https://dl.google.com$path";
    log.print("info: cmdline-tools is at '$url'.");
    return URL(url);
  }
}
