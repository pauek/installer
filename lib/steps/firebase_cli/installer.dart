import 'package:installer/installer/context.dart';
import 'package:installer/steps.dart';
import 'package:path/path.dart';

Step iFirebaseCLI() {
  return Chain("FirebaseCLI", [
    If(
      Not(IsFirebaseCliInstalled()),
      then: RunCommand(
        "npm",
        args: ["install", "-g", "firebase-tools", "--force"],
        envPath: [
          () => dirname(ctx.getBinary("node")),
        ],
      ),
    ),
  ]);
}
