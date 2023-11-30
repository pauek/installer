import 'dart:io';

import 'package:installer/installer.dart';
import 'package:installer/steps.dart';
import 'package:path/path.dart';

class CreateShortcut extends SinglePriorStep {
  final String shortcutName;
  CreateShortcut(this.shortcutName) : super("Create Shortcut");

  @override
  Future run() async {
    if (!Platform.isWindows) {
      return installerError("Platform not supported");
    }
    final homeDir = getHomeDir();
    final shortcutExe = absolute(ctx.downloadDir, "Shortcut.exe");
    log.print("info: Shortcut.exe should be at $shortcutExe");

    // Download Shortcut.exe
    try {
      await downloadFile(url: shortcutExeDownloadUrl, path: shortcutExe);
    } catch (e) {
      log.print("Error: couldn't download file");
      log.print(e.toString());
      return installerError("Didn't create shortcut");
    }

    // We find out first if the Desktop folder exists, since
    // it doesn't with Windows users who opted in to OneDrive.
    String shortcutFile = join(homeDir, "$shortcutName.lnk");
    if (Directory(join(homeDir, "Desktop")).existsSync()) {
      shortcutFile = join(homeDir, "Desktop", "$shortcutName.lnk");
    }

    final targetExe = ctx.getBinary("nu");
    final shortcutProcess = await Process.run(shortcutExe, [
      "/f:$shortcutFile",
      "/a:c",
      "/t:$targetExe",
      "/w:$homeDir",
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