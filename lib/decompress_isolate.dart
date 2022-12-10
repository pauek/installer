import 'dart:isolate';

import 'package:archive/archive_io.dart';

Future isolatedExtractFileToDisk(file, targetDir) async {
  final p = ReceivePort();
  await Isolate.spawn(_isolateExtractFileToDisk, [p.sendPort, file, targetDir]);
  await p.first;
}

void _isolateExtractFileToDisk(List args) async {
  SendPort rp = args[0];
  String file = args[1], targetDir = args[2];
  Object result;
  try {
    extractFileToDisk(file, targetDir);
    result = true;
  } catch (e) {
    result = e;
  }
  Isolate.exit(rp, result);
}
