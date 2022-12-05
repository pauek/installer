import 'dart:io';

import 'package:installer2/steps/step.dart';
import 'package:installer2/steps/types.dart';
import 'package:path/path.dart';

class Rename extends SinglePriorStep {
  @override
  Future run() async {
    final dir = ((await input) as Dirname).value;
    final base = basename(dir);
  }
}
