import 'dart:io';

import 'package:installer/installer.dart';
import 'package:installer/steps/step.dart';
import 'package:installer/steps/types.dart';
import 'package:path/path.dart';

class Rename extends SinglePriorStep {
  final String to;
  Rename({required this.to}) : super("Rename to $to");

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
