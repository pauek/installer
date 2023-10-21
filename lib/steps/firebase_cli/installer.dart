import 'package:installer/steps.dart';

Step iFirebaseCLI() {
  return Chain("FirebaseCLI", [
    If(
      Not(IsFirebaseCliInstalled()),
      then: RunCommand("npm", ["install", "-g", "firebase-tools"]),
    ),
  ]);
}