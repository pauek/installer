Future<void> func2() async {
  print("func2");
  await Future.delayed(Duration(seconds: 1));
  throw "fuck!";
}

Future<void> func1() async {
  print("func1");
  await Future.delayed(Duration(seconds: 1));
  await func2();
}

void main(List<String> args) async {
  try {
    await func1();
  } catch (e) {
    print("Error: $e");
  }
}
