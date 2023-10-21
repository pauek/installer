import 'package:html/parser.dart';
import 'package:http/http.dart' as http;
import 'package:installer/installer.dart';
import 'package:installer/steps/step.dart';
import 'package:installer/steps/types.dart';

const url7z = "https://www.7-zip.org/download.html";

class Get7zDownloadURL extends Step {
  Get7zDownloadURL() : super("Get 7z download URL");

  @override
  Future run() async {
    final response = await http.get(Uri.parse(url7z));
    final document = parse(response.body);
    final anchorList = document.querySelectorAll('td.Item a');
    String url = "";
    for (final anchor in anchorList) {
      final href = anchor.attributes['href'];
      if (href == null) {
        continue;
      }
      if (anchor.text == "Download" && href.contains("extra")) {
        final base = Uri.parse(url7z);
        final merged = Uri(
          host: base.host,
          scheme: base.scheme,
          path: "/$href",
        );
        url = merged.toString();
      }
    }
    if (url.isEmpty) {
      return installerError("7z download URL not found");
    }
    log.print("info: 7z is at '$url'.");
    return URL(url);
  }
}
