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

Future<bool> isDirectory(String dirPath) async {
  return await Directory(dirPath).exists();
}

Future<void> downloadFile(String url, String path) async {
  final response = await http.get(Uri.parse(url));
  await File(path).writeAsBytes(response.bodyBytes);
}

Future<void> decompressFile(String file, String targetDir) async {
  await ensureDir(targetDir);
  final cmd = ctx.getBinary("7z");
  await Process.run(cmd, ["x", file], workingDirectory: targetDir);
}

final _gitVersionRegex = RegExp(r"^git version (.*)$");
Future<String?> getInstalledGitVersion() async {
  final result = await Process.run(
    "git",
    ["--version"],
    runInShell: true,
    stdoutEncoding: Encoding.getByName("utf-8"),
  );
  final match = _gitVersionRegex.firstMatch(result.stdout.trim());
  return match?.group(1);
}

final _gitOriginRegex = RegExp(r"^origin	(\w+) \(fetch\)");
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
    for (final line in result.stderr.toString().trim().split("\n")) {
      log.print(" >> $line");
    }
    return null;
  }
  final match = _gitOriginRegex.firstMatch(result.stdout.trim());
  return match?.group(1);
}
