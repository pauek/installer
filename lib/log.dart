import 'dart:io';

class Log {
  String filename;
  File file;
  late IOSink sink;

  Log(this.filename) : file = File(filename) {
    sink = file.openWrite();
  }

  close() async {
    await sink.close();
  }

  void print(String text) {
    sink.write("$text\n");
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
