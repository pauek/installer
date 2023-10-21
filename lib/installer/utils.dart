import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:installer/installer.dart';

extension ListSeparate on List {
  List<List<T>> separate<T>(Function(T) fn) {
    List<T> yes = [], no = [];
    for (final elem in this) {
      final discriminator = fn(elem);
      if (discriminator == true) {
        yes.add(elem);
      } else {
        no.add(elem);
      }
    }
    return [yes, no];
  }
}

class InstallerError extends Error {
  String message;
  InstallerError(this.message);

  @override
  String toString() => "InstallerError: $message";
}

installerError(String message) {
  throw InstallerError(message);
}

String getHomeDir() {
  final homeVar = Platform.isWindows ? 'userprofile' : 'HOME';
  final homeDir = Platform.environment[homeVar];
  if (homeDir == null) {
    return installerError("Cannot get user home directory!");
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

Future<bool> isAbsoluteDirectory(String dirPath) async {
  final dir = Directory(dirPath);
  final exists = await dir.exists();
  return exists && dir.isAbsolute;
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

Future decompress(
  String file,
  String targetDir, {
  bool eraseDirFirst = false,
}) async {
  if (eraseDirFirst) {
    try {
      await ensureEmptyDir(targetDir);
    } catch (e) {
      log.print("Couldn't empty dir $targetDir.");
      log.print("   >> $e");
      return installerError(
        "Couldn't empty dir $targetDir, see log for details.",
      );
    }
  }
  try {
    if (file.endsWith(".zip")) {
      return await isolatedExtractFileToDisk(file, targetDir);
    } else if (file.endsWith(".tar.gz")) {
      return await decompressTarGz(file, targetDir);
    } else if (file.endsWith(".7z")) {
      return await decompress7z(file, targetDir);
    } else {
      return Future.value(
          installerError("Do not know how to decompress $file"));
    }
  } catch (e) {
    log.print("Couldn't decompress $file.");
    log.print("    $e");
    return installerError(
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
    log.print("Error: running 'git remove -v'.");
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
  return installerError("Platform not supported");
}

Future<String> getArch() async {
  if (Platform.isWindows) {
    final result = Platform.environment['PROCESSOR_ARCHITECTURE'];
    if (result == "AMD64" || result == null) {
      return "x64";
    } else {
      return installerError("Unknown architecture");
    }
  } else {
    var arch = await getCommandOutput("uname", ["-m"]);
    if (arch == "x86_64") {
      arch = "x64";
    }
    return arch;
  }
}

Future decompress7z(String file, String targetDir) async {
  final cmd7z = ctx.getBinary("7zr");
  final result = await Process.run(
    cmd7z,
    ["x", file],
    workingDirectory: targetDir,
  );
  if (result.exitCode != 0) {
    final stderr = result.stderr.toString().trim();
    for (final line in stderr.split("\n")) {
      log.print(" >> $line");
    }
    return installerError("Decompression failed");
  }
}

Future decompressTarGz(String file, String targetDir) async {
  log.print("Decompressing .tar.gz '$file' into '$targetDir'");
  final gzFile = file;
  final tarFile = file.substring(0, file.length - ".gz".length);

  // .tar.gz --> .tar
  final cmd7za = ctx.getBinary("7za");
  log.print("info: Running '$cmd7za x $gzFile $tarFile'");
  final result1 = await Process.run(cmd7za, ["x", gzFile, tarFile]);
  if (result1.exitCode != 0) {
    final stderr = result1.stderr.toString().trim();
    for (final line in stderr.split("\n")) {
      log.print(" >> $line");
    }
    return installerError("Ungzip of .tar.gz failed");
  }
  log.print("Ungzip of $gzFile ok.");

  // Unpack .tar
  log.print("info: Running '$cmd7za e $tarFile'");
  final result2 = await Process.run(
    cmd7za,
    ["x", tarFile],
    workingDirectory: targetDir,
  );
  if (result2.exitCode != 0) {
    final stderr = result2.stderr.toString().trim();
    for (final line in stderr.split("\n")) {
      log.print(" >> $line");
    }
    return installerError("Unpacking of .tar failed");
  }
}

Future<String> getLastTag(String owner, String repo) async {
  final url = Uri.parse("https://api.github.com/repos/$owner/$repo/tags");
  final response = await http.get(url);

  if (response.statusCode != 200) {
    throw Exception("Failed to fetch tags: ${response.statusCode}");
  }

  final List tags = jsonDecode(response.body);
  if (tags.isEmpty) {
    throw Exception('No tags found for $owner/$repo');
  }

  return tags.first['name'];
}
