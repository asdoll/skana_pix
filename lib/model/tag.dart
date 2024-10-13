import 'illust.dart' show Illust;

class Tag {
  final String name;
  final String? translatedName;

  const Tag(this.name, this.translatedName);

  @override
  String toString() {
    return "$name${translatedName == null ? "" : "($translatedName)"}";
  }

  @override
  bool operator ==(Object other) {
    if (other is Tag) {
      return name == other.name;
    }
    return false;
  }

  @override
  int get hashCode => name.hashCode;
}

class TrendingTag {
  final Tag tag;
  final Illust illust;

  TrendingTag(this.tag, this.illust);
}