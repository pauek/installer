final semVerRegex = RegExp(r"^(\d+)\.(\d+)\.(\d+)");

class SemVer {
  late int major, minor, patch;

  SemVer(this.major, this.minor, this.patch);

  SemVer.fromName(String name) {
    final match = semVerRegex.firstMatch(name);
    if (match == null) {
      throw "Not a Semantic Version!";
    }
    major = int.parse(match.group(1)!);
    minor = int.parse(match.group(2)!);
    patch = int.parse(match.group(3)!);
  }

  bool operator >(SemVer other) {
    return major > other.major || minor > other.minor || patch > other.patch;
  }

  bool operator <(SemVer other) {
    return major < other.major || minor < other.minor || patch < other.patch;
  }

  @override
  bool operator ==(Object other) {
    if (other is SemVer) {
      return major == other.major &&
          minor == other.minor &&
          patch == other.patch;
    } else {
      return false;
    }
  }

  @override
  int get hashCode => patch + 1000 * (minor + 1000 * major);

  @override
  String toString() => "v$major.$minor.$patch";
}
