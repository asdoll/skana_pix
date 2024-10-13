enum KeywordMatchType {
  tagsPartialMatches("Tags partial match"),
  tagsExactMatch("Tags exact match"),
  titleOrDescriptionSearch("Title or description search");

  final String text;

  const KeywordMatchType(this.text);

  @override
  toString() => text;

  String toParam() => switch (this) {
        KeywordMatchType.tagsPartialMatches => "partial_match_for_tags",
        KeywordMatchType.tagsExactMatch => "exact_match_for_tags",
        KeywordMatchType.titleOrDescriptionSearch => "title_and_caption"
      };
}

enum FavoriteNumber {
  unlimited(-1),
  f500(500),
  f1000(1000),
  f2000(2000),
  f5000(5000),
  f7500(7500),
  f10000(10000),
  f20000(20000),
  f50000(50000),
  f100000(100000);

  final int number;
  const FavoriteNumber(this.number);

  @override
  toString() =>
      this == FavoriteNumber.unlimited ? "Unlimited" : "$number Bookmarks";

  String toParam() =>
      this == FavoriteNumber.unlimited ? "" : " ${number}users入り";
}

enum SearchSort {
  newToOld,
  oldToNew,
  popular,
  popularMale,
  popularFemale;

  bool get isPremium => false;//appdata.account?.user.isPremium == true;

  static List<SearchSort> get availableValues => [
        SearchSort.newToOld,
        SearchSort.oldToNew,
        SearchSort.popular,
        //if (appdata.account?.user.isPremium == true) SearchSort.popularMale,
        //if (appdata.account?.user.isPremium == true) SearchSort.popularFemale
      ];

  @override
  toString() {
    if (this == SearchSort.popular) {
      return isPremium ? "Popular" : "Popular(limited)";
    } else if (this == SearchSort.newToOld) {
      return "New to old";
    } else if (this == SearchSort.oldToNew) {
      return "Old to new";
    } else if (this == SearchSort.popularMale) {
      return "Popular(Male)";
    } else {
      return "Popular(Female)";
    }
  }

  String toParam() => switch (this) {
        SearchSort.newToOld => "date_desc",
        SearchSort.oldToNew => "date_asc",
        SearchSort.popular => "popular_desc",
        SearchSort.popularMale => "popular_male_desc",
        SearchSort.popularFemale => "popular_female_desc",
      };
}

enum AgeLimit {
  unlimited("Unlimited"),
  allAges("All ages"),
  r18("R18");

  final String text;

  const AgeLimit(this.text);

  @override
  toString() => text;

  String toParam() => switch (this) {
        AgeLimit.unlimited => "",
        AgeLimit.allAges => " -R-18",
        AgeLimit.r18 => "R-18",
      };
}

class SearchOptions {
  KeywordMatchType matchType = KeywordMatchType.tagsPartialMatches;
  FavoriteNumber favoriteNumber = FavoriteNumber.unlimited;
  SearchSort sort = SearchSort.newToOld;
  DateTime? startTime;
  DateTime? endTime;
  AgeLimit ageLimit = AgeLimit.unlimited;
}
