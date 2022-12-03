import 'package:installer2/steps/step.dart';
import 'package:installer2/steps/types.dart';

class GiveURL extends Step<URL> {
  String url;
  GiveURL(this.url);

  @override
  Future<URL> run() => Future.value(URL(url));
}
