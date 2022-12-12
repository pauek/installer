import 'package:html/parser.dart';
import 'package:installer2/log.dart';
import 'package:installer2/steps/step.dart';
import 'package:http/http.dart' as http;
import 'package:installer2/steps/types.dart';
import 'package:installer2/utils.dart';

class GetFontDownloadURL extends SinglePriorStep {
  final String fontName;
  GetFontDownloadURL({required this.fontName});

  @override
  Future run() async {
    return withMessage("Getting font URL", () async {
      try {
        final response = await http.get(
          Uri.parse("https://www.nerdfonts.com/font-downloads"),
        );
        final document = parse(response.body);
        final buttonList = document.querySelectorAll('a.nerd-font-button');
        String url = "";
        for (final button in buttonList) {
          final href = button.attributes['href'];
          if (href != null && href.contains(fontName)) {
            url = href;
            break;
          }
        }
        if (url.isEmpty) {
          return error("Font download URL not found");
        }
        return URL(url);
      } catch (e) {
        log.print("ERROR: Get Fonts URL error:");
        log.printOutput(e.toString());
        return error("Get Fonts URL error: $e");
      }
    });
  }
}
