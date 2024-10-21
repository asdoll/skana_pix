import 'package:skana_pix/pixiv_dart_api.dart';

class HistoryManager {
  static final HistoryManager _instance = HistoryManager._internal();

  factory HistoryManager() {
    return _instance;
  }

  HistoryManager._internal();

  final List<dynamic> _histories = [];

  List<dynamic> get histories => _histories;

  void addHistory(dynamic views) {
    if(!(views is Illust|| views is Novel)){
      return;
    }
    if (_histories.contains(views)) {
      _histories.remove(views);
    }
    _histories.add(views);
  }

  void removeHistory(dynamic views) {
    _histories.remove(views);
  }

  void clearHistories() {
    _histories.clear();
  }
}