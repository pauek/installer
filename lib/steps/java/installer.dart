import 'package:installer/steps/add_binary.dart';
import 'package:installer/steps/decompress.dart';
import 'package:installer/steps/download_file.dart';
import 'package:installer/steps/give_url.dart';
import 'package:installer/steps/if.dart';
import 'package:installer/steps/java/is_java_installed.dart';
import 'package:installer/steps/not.dart';
import 'package:installer/steps/step.dart';

Step iJavaJDK() {
  return Chain("Java", [
    If(
      Not(IsJavaInstalled()),
      then: Chain.noPrefix([
        GiveURL(
          "https://android.googlesource.com"
          "/platform/prebuilts/jdk/jdk17/+archive/refs/heads/main/windows-x86.tar.gz",
        ),
        DownloadFile(),
        Decompress(into: "java"),
        AddToEnv(dir: "java", items: [
          EnvVariable("JAVA_HOME"),
          Binary("java", all: "bin/java"),
        ])
      ]),
    )
  ]);
}
