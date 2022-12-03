class Value<T> {
  T value;
  Value(this.value);

  bool get isNull => value == null;
  bool get isNotNull => value != null;
}

class Filename extends Value<String> {
  Filename(super.value);
}

class URL extends Value<String> {
  URL(super.value);
}

class Dirname extends Value<String> {
  Dirname(super.value);
}
