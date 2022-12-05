import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:installer2/context.dart';
import 'package:installer2/log.dart';

String getHomeDir() {
  final homeVar = Platform.isWindows ? 'userprofile' : 'HOME';
  final homeDir = Platform.environment[homeVar];
  if (homeDir == null) {
    throw "Cannot get user home directory!";
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
    await removeDirRecursively(dir);
  }
  await ensureDir(dir);
}

Future<bool> isDirectory(String dirPath) async {
  return await Directory(dirPath).exists();
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

Future<DirList> listDirectories(String dirPath) async {
  final dirList = DirList();
  await for (final file in Directory(dirPath).list()) {
    if (await isDirectory(file.path)) {
      dirList.dirs.add(file.path);
    } else {
      dirList.files.add(file.path);
    }
  }
  return dirList;
}

Future<String?> decompressFile(String file, String targetDir) async {
  await ensureEmptyDir(targetDir);
  late ProcessResult? result;
  if (file.endsWith(".7z") || file.endsWith(".zip")) {
    final cmd = ctx.getBinary("7z");
    result = await Process.run(cmd, ["x", file], workingDirectory: targetDir);
  } else if (file.endsWith(".tar.gz")) {
    final tar = ctx.getBinary("tar");
    result = await Process.run(tar, ["xzf", file], workingDirectory: targetDir);
  } else {
    throw "Do not know how to decompress $file";
  }
  if (result.exitCode != 0) {
    final stderr = result.stderr.toString().trim();
    for (final line in stderr.split(" ")) {
      log.print(" >> $line");
    }
    throw "Decompression failed";
  }
  return targetDir;
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
    log.showOutput(result.stderr.toString().trim());
    return null;
  }
  final match = _gitOriginRegex.firstMatch(result.stdout.trim());
  return match?.group(1);
}

Future<String> getCommandOutput(String cmd, List<String> args) async {
  final result = await Process.run(cmd, args);
  return result.stdout.toString().trim();
}
