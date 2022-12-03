import 'dart:io';

class Log {
  String filename;
  File file;
  late IOSink sink;

  Log(this.filename) : file = File(filename) {
    sink = file.openWrite();
  }

  close() {
    sink.close();
  }

  Future<void> print(String text) async {
    sink.write("$text\n");
    await sink.flush();
  }

  static Log? _instance;
  static init({required String filename}) {
    _instance = Log(filename);
  }
}

Log get log {
  if (Log._instance == null) {
    throw "Call Log.init(...) first!";
  }
  return Log._instance!;
}
