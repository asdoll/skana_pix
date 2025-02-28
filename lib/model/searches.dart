List<String> search_target = [
  "partial_match_for_tags",
  "exact_match_for_tags",
  "title_and_caption"
];
List<String> search_target_name = [
  "Tags partial match",
  "Tags exact match",
  "Title or description search"
];

List<String> search_target_novel = [
    "partial_match_for_tags",
    "exact_match_for_tags",
    "text",
    "keyword"
  ];
List<String> search_target_name_novel = [
  "Tags partial match",
  "Tags exact match",
  "Text",
  "Keyword"
];

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

List<String> search_sort = [
  "date_desc",
  "date_asc",
  "popular_desc",
  "popular_male_desc",
  "popular_female_desc",
];

List<String> search_sort_name = [
  "Popular",
  "New to old",
  "Old to new",
  "Popular(Male)",
  "Popular(Female)",
];

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
  String searchTarget = search_target[0];
  String searchTargetNovel = search_target_novel[0];
  int favoriteNumber = 0;
  String selectSort = search_sort[0];
  DateTime? startTime;
  DateTime? endTime;
  AgeLimit ageLimit = AgeLimit.unlimited;
  List<int> premiumNum = [];
  bool searchAI = true;
}

List<List<int>> premiumStarNum = [
  [],
  [10000],
  [50000, 99999],
  [10000, 49999],
  [5000, 9999],
  [1000, 4999],
  [500, 999],
  [300, 499],
  [100, 299],
  [50, 99],
  [30, 49],
  [10, 29],
];

List<int> starNum = [
  0,
  100,
  250,
  500,
  1000,
  5000,
  7500,
  10000,
  20000,
  30000,
  50000,
];
