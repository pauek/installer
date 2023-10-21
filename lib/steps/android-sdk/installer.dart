import 'package:installer/steps/add_binary.dart';
import 'package:installer/steps/android-sdk/accept_android_licenses.dart';
import 'package:installer/steps/android-sdk/cmdline_tools_url.dart';
import 'package:installer/steps/android-sdk/is_cmdline_tools_installed.dart';
import 'package:installer/steps/decompress.dart';
import 'package:installer/steps/delay.dart';
import 'package:installer/steps/download_file.dart';
import 'package:installer/steps/if.dart';
import 'package:installer/steps/not.dart';
import 'package:installer/steps/rename.dart';
import 'package:installer/steps/run_sdk_manager.dart';
import 'package:installer/steps/step.dart';

Step iAndroidSdk() {
  return Chain("Android SDK", [
    If(
      Not(IsCmdlineToolsInstalled()),
      then: Chain.noPrefix([
        GetAndroidCmdlineToolsURL(),
        DownloadFile(),
        Decompress(into: r"android-sdk\cmdline-tools"),
        Delay(duration: Duration(milliseconds: 500)),
        Rename(from: "cmdline-tools", to: "latest"),
        AddToEnv(dir: "android-sdk", items: [
          EnvVariable("ANDROID_HOME"),
          Binary(
            "sdkmanager",
            win: r"cmdline-tools\latest\bin\sdkmanager.bat",
            all: "cmdline-tools/latest/bin/sdkmanager",
          ),
        ]),
      ]),
    ),
    RunSdkManager(
      ["platforms;android-33", "build-tools;33.0.1", "platform-tools"],
    ),
    AcceptAndroidLicenses(),
  ]);
}
