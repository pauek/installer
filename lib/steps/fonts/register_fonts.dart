import 'dart:io';

import 'package:installer2/context.dart';
import 'package:installer2/log.dart';
import 'package:installer2/steps/nushell/configure_nushell.dart';
import 'package:installer2/steps/step.dart';
import 'package:installer2/utils.dart';
import 'package:path/path.dart';

class RegisterFonts extends SinglePriorStep {
  @override
  Future<void> run() async {
    await waitForInput();

    return await withMessage("Registering Fonts", () async {
      // Get the font list
      final fontsDir = join(ctx.targetDir, "fonts");
      final fontList = [];
      await for (final file in Directory(fontsDir).list()) {
        if (file.path.endsWith(".ttf") &&
            file.path.contains("Windows Compatible") &&
            file.path.contains("Mono")) {
          fontList.add(file.path);
        }
      }
      for (final font in fontList) {
        log.print("Adding font '$font'");
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
      log.print("Registering fonts produced:");
      log.showOutput(result.stderr);
      return result.exitCode == 0;
    });
  }
}
