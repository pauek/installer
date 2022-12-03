import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:installer2/context.dart';

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

Future<void> downloadFile(String url, String path) async {
  final response = await http.get(Uri.parse(url));
  await File(path).writeAsBytes(response.bodyBytes);
}

Future<void> decompressFile(String file, String targetDir) async {
  await ensureDir(targetDir);
  final cmd = ctx.getBinary("7z");
  await Process.run(cmd, ["x", file], workingDirectory: targetDir);
}

Future<bool> isGitInstalled() async {
  final result = await Process.run("git", []);
  return result.exitCode == 0;
}
