import 'package:console/console.dart';
import 'package:installer/installer.dart';
import 'package:installer/steps/step.dart';

class If extends Step {
  final Step cond;
  final Step then;
  final Step? orelse;
  If(this.cond, {required this.then, this.orelse})
      : super("if (${cond.title}) ${then.title} ${orelse?.title ?? ""}");

  @override
  CursorPosition setPos(CursorPosition p) {
    final next = super.setPos(p);
    cond.setPos(p);
    then.setPos(p);
    orelse?.setPos(p);
    return next;
  }

  @override
  Future run() async {
    if (input is InstallerError) {
      return input;
    }
    final condResult = await cond.runChecked();
    if (condResult is InstallerError) {
      return condResult;
    }
    if (condResult is! bool) {
      return installerError("Condition in If didn't return boolean");
    }
    if (condResult) {
      return then.runChecked();
    } else {
      show("");
      if (orelse != null) {
        return orelse!.runChecked();
      } else {
        return null;
      }
    }
  }
}
