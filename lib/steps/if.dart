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
    final result = await cond.run();
    if (result is InstallerError) {
      return result;
    }
    if (result is! bool) {
      return InstallerError("Condition in If didn't return boolean");
    }
    if (result) {
      return await then.run();
    } else {
      if (orelse != null) {
        return await orelse!.run();
      } else {
        return null;
      }
    }
  }
}
