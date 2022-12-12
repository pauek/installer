import 'dart:io';

import 'package:installer2/context.dart';
import 'package:installer2/steps/step.dart';
import 'package:installer2/utils.dart';
import 'package:path/path.dart';

class CreateShortcut extends SinglePriorStep {
  CreateShortcut() : super("Create Shortcut");

  @override
  Future run() async {
    if (!Platform.isWindows) {
      return error("Platform not supported");
    }
    final shortcutExe = join(ctx.downloadDir, "Shortcut.exe");
    await downloadFile(
      url: "https://files.pauek.info/Shortcut.exe",
      path: shortcutExe,
    );
    final shortcutFile = join(getHomeDir(), "Desktop", "Flutter.lnk");
    final targetExe = ctx.getBinary("nu");
    final shortcutProcess = await Process.run(shortcutExe, [
      "/f:$shortcutFile",
      "/a:c",
      "/t:$targetExe",
      "/w:${getHomeDir()}",
      "/r:1",
    ]);
    return shortcutProcess.exitCode == 0;
  }
}

/*

  Shortcut.exe /F:filename /A:C|E|Q [/T:target] [/P:parameters] [/W:workingdir]
          [/R:runstyle] [/I:icon,index] [/H:hotkey] [/D:description]

  /F:filename    : Specifies the .LNK shortcut file.
  /A:action      : Defines the action to take (C=Create, E=Edit or Q=Query).
  /T:target      : Defines the target path and file name the shortcut points to.
  /P:parameters  : Defines the command-line parameters to pass to the target.
  /W:working dir : Defines the working directory the target starts with.
  /R:run style   : Defines the window state (1=Normal, 3=Max, 7=Min).
  /I:icon,index  : Defines the icon and optional index (file.exe or file.exe,0).
  /H:hotkey      : Defines the hotkey, a numeric value of the keyboard shortcut.
  /D:description : Defines the description (or comment) for the shortcut.
  
*/