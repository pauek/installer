import 'dart:io';

import 'package:installer2/steps/step.dart';
import 'package:installer2/steps/types.dart';
import 'package:installer2/utils.dart';
import 'package:path/path.dart';

class Rename extends SinglePriorStep {
  final String from, to;
  Rename({required this.from, required this.to}) : super("Rename $from to $to");

  @override
  Future run() async {
    if (input is! Dirname) {
      throw InstallerError("Rename input is not a Dirname");
    }
    final dir = (input as Dirname).value;
    final basedir = dirname(dir);
    await Directory(dir).rename(join(basedir, to));
  }
}
