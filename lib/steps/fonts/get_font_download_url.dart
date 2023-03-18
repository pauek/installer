import 'package:html/parser.dart';
import 'package:installer/steps/step.dart';
import 'package:http/http.dart' as http;
import 'package:installer/steps/types.dart';
import 'package:installer/utils.dart';

class GetFontDownloadURL extends SinglePriorStep {
  final String fontName;
  GetFontDownloadURL({required this.fontName}) : super("Get font download URL");

  @override
  Future run() async {
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
  }
}
