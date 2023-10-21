import 'dart:io';

import 'package:installer/installer.dart';
import 'package:installer/steps/nushell/configure_nushell.dart';
import 'package:installer/steps/step.dart';
import 'package:path/path.dart';

class RegisterFonts extends SinglePriorStep {
  RegisterFonts() : super("Register fonts");

  @override
  Future run() async {
    final fontsDir = input;
    // Get the font list
    final fontList = [];
    await for (final file in Directory(fontsDir).list()) {
      if (file.path.endsWith(".ttf") &&
          file.path.contains("Windows Compatible") &&
          file.path.contains("Mono")) {
        fontList.add(file.path);
      }
    }
    for (final font in fontList) {
      log.print("info: Adding font '$font'.");
    }

    // Create a script for PowerShell
    final scriptFile = join(ctx.downloadDir, "regfonts.ps1");
    await writeFile(
      scriptFile,
      [
        r"$FontCLSID = 0x14" + endl,
        r"$ShellObject = New-Object -ComObject Shell.Application" + endl,
        r"$Folder = $ShellObject.Namespace($FontCLSID)" + endl,
        for (final font in fontList) '\$Folder.CopyHere("$font")$endl',
      ].join(),
    );

    // Run PowerShell with the script
    final result = await Process.run("powershell.exe", [scriptFile]);
    log.print("info: Registering fonts produced:");
    log.printOutput(result.stderr);
    return result.exitCode == 0;
  }
}
