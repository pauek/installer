import 'package:console/console.dart';
import 'package:installer2/steps/step.dart';

class If extends Step {
  final Step<bool> cond;
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
    show("");
    if (!(await cond.run())) {
      await then.run();
    } else {
      if (orelse != null) {
        await orelse!.run();
      }
    }
  }
}
