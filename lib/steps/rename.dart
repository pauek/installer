import 'dart:io';

import 'package:installer2/steps/step.dart';
import 'package:installer2/steps/types.dart';
import 'package:path/path.dart';

class Rename extends SinglePriorStep {
  final String from, to;
  Rename({required this.from, required this.to});

  @override
  Future run() async {
    final dir = ((await input) as Dirname).value;
    final basedir = dirname(dir);
    await Directory(dir).rename(join(basedir, to));
  }
}
