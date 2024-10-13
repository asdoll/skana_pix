class Parser {
  static List<String> parseImgsInNovel(String content) {
    var reg = RegExp(r'\[pixivimage.{0,15}\]');
    var regPre = RegExp(r'\[pixivimage:');
    var regEnd = RegExp(r'\]');
    Iterable<Match> matches = reg.allMatches(content);
    List<String> imgs = [];
    for (final Match m in matches) {
      String match = m[0]!;
      imgs.add(match.replaceAll(regPre, '').replaceAll(regEnd, ''));
    }
    return imgs;
  }
}
