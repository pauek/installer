import 'package:html/parser.dart';
import 'package:http/http.dart' as http;
import 'package:installer2/log.dart';
import 'package:installer2/steps/step.dart';
import 'package:installer2/steps/types.dart';

const url7z = "https://www.7-zip.org/download.html";

class Get7zDownloadURL extends Step {
  @override
  Future run() async {
    return await withMessage("Getting font URL", () async {
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
        throw "7z download URL not found";
      }
      log.print("URL for 7z is '$url'");
      return URL(url);
    });
  }
}
