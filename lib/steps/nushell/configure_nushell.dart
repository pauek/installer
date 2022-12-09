import 'dart:io';

import 'package:installer2/context.dart';
import 'package:installer2/log.dart';
import 'package:installer2/steps/step.dart';
import 'package:installer2/utils.dart';
import 'package:path/path.dart';

const github = "https://raw.githubusercontent.com";
const route = "/nushell/nushell/main/crates/nu-utils/src/sample_config/";

Future<String> getNuPath(name) async {
  return await getCommandOutput(ctx.getBinary("nu"), ["-c", "\$nu.$name-path"]);
}

String dartPubDir() {
  final home = getHomeDir();
  if (Platform.isWindows) {
    return "$home\\AppData\\Local\\Pub\\Cache\\bin";
  } else if (Platform.isMacOS || Platform.isLinux) {
    return "$home/.pub-cache/bin";
  } else {
    return error("Platform not supported");
  }
}

String get endl {
  if (Platform.isWindows) {
    return "\r\n";
  } else if (Platform.isLinux) {
    return "\n";
  } else if (Platform.isMacOS) {
    return "\n"; // "\r" ??
  } else {
    return error("Platform not supported");
  }
}

String get pathVariable {
  if (Platform.isWindows) {
    return "Path";
  } else if (Platform.isLinux || Platform.isMacOS) {
    return "PATH";
  } else {
    return error("Platform not supported");
  }
}

String addEndl(String line) => "$line$endl";

Future<void> addLinesToFile(String path, List<String> lines) async {
  final file = await File(path).open(mode: FileMode.writeOnlyAppend);
  log.print("Added to $path");
  for (final line in lines) {
    log.print(" >> $line");
  }
  await file.writeString(lines.map(addEndl).join(""));
  await file.close();
}

class FileInfo {
  String path, dir, filename;
  FileInfo({required this.path, required this.dir, required this.filename});
}

class ConfigureNushell extends SinglePriorStep {
  @override
  Future run() async {
    final result = await waitForInput();
    if (result is InstallerError) {
      return result;
    }
    return withMessage(
      "Configuring nushell",
      () async {
        final file = <String, String>{};

        // TODO: Detect if these files exist first!!
        for (final which in ['env', 'config']) {
          final path = (await getNuPath(which)).trim();
          await ensureDir(dirname(path));
          await downloadFile(
            url: "$github${route}default_$which.nu",
            path: path,
          );
          file[which] = path;
        }

        Set<String> envpath = {}; // deduplicate
        for (final path in ctx.binaries.values) {
          envpath.add(dirname(path));
        }

        // TODO: Add lines in a controlled section
        await addLinesToFile(file['env']!, [
          "let-env $pathVariable = (\$env.$pathVariable | prepend '${dartPubDir()}')",
          for (final path in envpath)
            "let-env $pathVariable = (\$env.$pathVariable | prepend '$path')",
          for (final entry in ctx.variables)
            "let-env ${entry.variable} = '${entry.value}'",
        ]);

        await addLinesToFile(file['config']!, [
          "let-env config = {",
          "  show_banner: false",
          "}",
        ]);

        return true;
      },
    );
  }
}
