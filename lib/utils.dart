import 'dart:convert';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:http/http.dart' as http;
import 'package:installer2/context.dart';
import 'package:installer2/log.dart';

class InstallerError extends Error {
  String message;
  InstallerError(this.message);

  @override
  String toString() => "InstallerError: $message";
}

error(String message) {
  throw InstallerError(message);
}

String getHomeDir() {
  final homeVar = Platform.isWindows ? 'userprofile' : 'HOME';
  final homeDir = Platform.environment[homeVar];
  if (homeDir == null) {
    return error("Cannot get user home directory!");
  }
  return homeDir;
}

Future<void> ensureDir(String dir) async {
  await Directory(dir).create(recursive: true);
}

Future<void> removeDirRecursively(String dirPath) async {
  await Directory(dirPath).delete(recursive: true);
}

Future<void> ensureEmptyDir(String dir) async {
  if (await Directory(dir).exists()) {
    if (await isDirEmpty(dir)) {
      return;
    }
    await removeDirRecursively(dir);
  }
  await ensureDir(dir);
}

Future<bool> isFilePresent(String filePath) async {
  return File(filePath).exists();
}

Future<bool> isDirectory(String dirPath) async {
  return await Directory(dirPath).exists();
}

Future<void> writeFile(String path, String contents) async {
  await File(path).writeAsString(contents, flush: true);
}

Future<bool> downloadFile({required String url, required String path}) async {
  final response = await http.get(Uri.parse(url));
  if (response.statusCode == 200) {
    await File(path).writeAsBytes(response.bodyBytes);
    return true;
  } else {
    return false;
  }
}

class DirList {
  List<String> dirs = [], files = [];
}

Future<List<String>> dirList(String dirPath) async {
  try {
    List<String> result = [];
    await for (final entity in Directory(dirPath).list()) {
      result.add(entity.path);
    }
    return result;
  } catch (e) {
    return [];
  }
}

Future<bool> isDirEmpty(String dirPath) async =>
    (await dirList(dirPath)).isEmpty;

Future<DirList> dirListSubdirectories(String dirPath) async {
  final dirList = DirList();
  await for (final entity in Directory(dirPath).list()) {
    if (await isDirectory(entity.path)) {
      dirList.dirs.add(entity.path);
    } else {
      dirList.files.add(entity.path);
    }
  }
  return dirList;
}

Future decompress(String file, String targetDir) async {
  try {
    await ensureEmptyDir(targetDir);
  } catch (e) {
    log.print("Couldn't empty dir $targetDir");
    log.print(" >> $e");
    return InstallerError(
      "Couldn't empty dir $targetDir, see log for details.",
    );
  }
  try {
    if (file.endsWith(".zip")) {
      await extractFileToDisk(file, targetDir);
    } else if (file.endsWith(".tar.gz")) {
      await extractFileToDisk(file, targetDir);
    } else if (file.endsWith(".7z")) {
      await decompress7z(file, targetDir);
    } else {
      return error("Do not know how to decompress $file");
    }
  } catch (e) {
    log.print("Couldn't decompress $file");
    log.print(" >> $e");
    return InstallerError(
      "Couldn't decompress $file, see log for details.",
    );
  }
}

final _gitOriginRegex = RegExp(r"^origin\s+(.+)\s+\(fetch\)");
Future<String?> getGitRemote(String repoDir) async {
  if (!(await isDirectory(repoDir))) {
    return null;
  }
  final result = await Process.run(
    ctx.getBinary("git"),
    ["remote", "-v"],
    workingDirectory: repoDir,
    stdoutEncoding: Encoding.getByName("utf-8"),
  );
  if (result.exitCode != 0) {
    log.print("Error running 'git remove -v'");
    log.printOutput(result.stderr.toString().trim());
    return null;
  }
  final match = _gitOriginRegex.firstMatch(result.stdout.trim());
  return match?.group(1);
}

Future<String> getCommandOutput(String cmd, List<String> args) async {
  final result = await Process.run(cmd, args);
  return result.stdout.toString().trim();
}

Future<String> getOS() async {
  if (Platform.isWindows) {
    return "win";
  } else if (Platform.isMacOS) {
    return "mac";
  } else if (Platform.isLinux) {
    return "linux";
  }
  return error("Platform not supported");
}

Future<String> getArch() async {
  if (Platform.isWindows) {
    final result = Platform.environment['PROCESSOR_ARCHITECTURE'];
    if (result == "AMD64" || result == null) {
      return "x64";
    } else {
      return error("Unknown architecture");
    }
  } else {
    var arch = await getCommandOutput("uname", ["-m"]);
    if (arch == "x86_64") {
      arch = "x64";
    }
    return arch;
  }
}

Future<void> decompress7z(String file, String targetDir) async {
  final cmd = ctx.getBinary("7z");
  final result = await Process.run(
    cmd,
    ["x", file],
    workingDirectory: targetDir,
  );
  if (result.exitCode != 0) {
    final stderr = result.stderr.toString().trim();
    for (final line in stderr.split("\n")) {
      log.print(" >> $line");
    }
    return error("Decompression failed");
  }
}
