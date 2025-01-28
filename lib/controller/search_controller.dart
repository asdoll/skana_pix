import 'package:get/get.dart';
import 'package:skana_pix/controller/connector.dart';
import 'package:skana_pix/controller/exceptions.dart';
import 'package:skana_pix/controller/logging.dart';
import 'package:skana_pix/model/tag.dart';

class SuggestionStore extends GetxController {
  RxList<Tag> autoWords = RxList.empty();
  void fetch(String query) async {
    if (query.isEmpty) return;
    try {
      ConnectManager()
          .apiClient
          .getSearchAutoCompleteKeywords(query)
          .then((value) {
        if (!value.success) throw BadRequestException("Network error");
        autoWords.clear();
        autoWords.addAll(value.data);
        autoWords.refresh();
      });
    } catch (e) {
      log.e(e);
    }
  }

  @override
  String toString() {
    return '''
autoWords: $autoWords
    ''';
  }
}
