import 'package:console/console.dart';
import 'package:installer2/steps/step.dart';
import 'package:installer2/utils.dart';

class If extends Step {
  final Step cond;
  final Step then;
  final Step? orelse;
  If(this.cond, {required this.then, this.orelse});

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
    final result = await waitForInput();
    if (result is InstallerError) {
      return result;
    }
    final condResult = await cond.run();
    if (condResult is InstallerError) {
      return condResult;
    }
    if (condResult is! bool) {
      return error("Condition in If didn't return boolean");
    }
    if (condResult) {
      return await then.run();
    } else {
      show("");
      if (orelse != null) {
        return await orelse!.run();
      } else {
        return null;
      }
    }
  }
}
