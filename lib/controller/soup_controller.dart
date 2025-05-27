import 'dart:io';

import 'package:dio/dio.dart' as dio;
import 'package:get/get.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart';
import 'package:skana_pix/controller/connector.dart';
import 'package:skana_pix/controller/logging.dart';
import 'package:skana_pix/controller/settings.dart';
import 'package:skana_pix/model/spotlight.dart';
import 'package:skana_pix/utils/leaders.dart';
import 'package:skana_pix/utils/loading_indicator.dart';

class SoupFetcher extends GetxController {
  RxList<AmWork> amWorks = RxList();

  SoupFetcher();

  final soupDio = dio.Dio(dio.BaseOptions(headers: {
    HttpHeaders.acceptLanguageHeader: settings.getLocale().contains('zh')
        ? (settings.getLocale() == "zh_TW" ? 'zh-TW,zh;q=0.9' : 'zh-CN,zh;q=0.9')
        : 'en-US,en;q=0.9',
    'user-agent':
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/85.0.4183.26 Safari/537.36 Edg/85.0.564.13',
    HttpHeaders.refererHeader: 'https://www.pixivision.net/zh/',
  }));

  var description = '';

  fetch(String url) async {
    try {
      if (settings.getLocale().contains('zh')) {
        _fetchCNTW(url);
      } else {
        _fetchEn(url);
      }
    } on Exception {
      Leader.showToast("404 NOT FOUND");
    } catch (e) {
      return;
    }
  }

  _fetchEn(url) async {
    dio.Response response = await soupDio.request(url);
    var document = parse(response.data);
    amWorks.clear();

    var nodes = document
        .getElementsByTagName("article")
        .first
        .getElementsByClassName('am__body')
        .first
        .children;

    dom.Element workInfo;
    if (nodes.first.attributes['class']!.contains('_feature')) {
      // feature article body
      nodes = nodes.first.children;
      description = '';
    } else {
      workInfo = document
          .getElementsByTagName("article")
          .first
          .getElementsByTagName('header')
          .first;
      description = workInfo.toTargetString();
    }
    for (var value in nodes) {
      try {
        if (!value.attributes['class']!.contains('illust')) {
          continue;
        }
        AmWork amWork = AmWork();
        for (var aa in value.getElementsByTagName('a')) {
          var a = aa.attributes['href'];
          var segments = Uri.parse(a!).pathSegments;
          if (a.startsWith('https') &&
              segments.length > 2 &&
              segments[segments.length - 2] == 'artworks') {
            amWork.arworkLink = a;
            amWork.showImage =
                value.getElementsByTagName('img')[1].attributes['src']!;
            amWork.title = value.getElementsByTagName('h3').first.text;
          } else if (a.startsWith('https') &&
              segments.length > 2 &&
              segments[segments.length - 2] == 'users') {
            amWork.userLink = a;
            amWork.user = value.getElementsByTagName('p').first.text;
            amWork.userImage =
                value.getElementsByTagName('img').first.attributes['src']!;
          }
        }
        if (amWork.userLink == null || amWork.arworkLink == null) {
          continue;
        }
        amWorks.add(amWork);
      } catch (e) {
        log.e("soup fetch error");
      }
    }
  }

  _fetchCNTW(url) async {
    dio.Response response = await soupDio.request(url);
    var document = parse(response.data);
    amWorks.clear();

    var nodes = document
        .getElementsByTagName("article")
        .first
        .getElementsByClassName('am__body')
        .first
        .children;

    dom.Element workInfo;
    if (nodes.first.attributes['class']!.contains('_feature')) {
      // feature article body
      nodes = nodes.first.children;
      description = '';
    } else {
      workInfo = document
          .getElementsByTagName("article")
          .first
          .getElementsByTagName('header')
          .first;
      description = workInfo.toTargetString();
    }

    for (var value in nodes) {
      try {
        if (!value.attributes['class']!.contains('illust')) {
          continue;
        }
        AmWork amWork = AmWork();
        for (var aa in value.getElementsByTagName('a')) {
          var a = aa.attributes['href']!;
          if (a.contains('https://www.pixiv.net/artworks')) {
            amWork.arworkLink = a;
            amWork.showImage =
                value.getElementsByTagName('img')[1].attributes['src']!;
            amWork.title = value.getElementsByTagName('h3').first.text;
          } else if (a.contains('https://www.pixiv.net/users')) {
            amWork.userLink = a;
            amWork.user = value.getElementsByTagName('p').first.text;
            amWork.userImage =
                value.getElementsByTagName('img').first.attributes['src']!;
          }
        }
        if (amWork.userLink == null || amWork.arworkLink == null) {
          continue;
        }
        amWorks.add(amWork);
      } catch (e) {
        log.e("soup fetch error");
      }
    }
  }
}

extension ElementExt on dom.Element {
  String toTargetString() {
    return getElementsByTagName('p')
        .map((e) => e.text)
        .toList()
        .toString()
        .replaceAll('[', '')
        .replaceAll(']', '')
        .replaceAll(',', '');
  }
}

class SpotlightStoreBase extends GetxController {
  RxList<SpotlightArticle> articles = RxList.empty();
  String? nextUrl;
  RxnString error = RxnString(null);
  Rx<LoadingState> loadingState = LoadingState.idle.obs;

  SpotlightStoreBase();

  Future<bool> fetch() async {
    loadingState.value = LoadingState.loading;
    loadingState.refresh();
    nextUrl = null;
    try {
      SpotlightResponse response =
          await ConnectManager().apiClient.getSpotlightArticles("all");
      if (response.nextUrl != null && response.nextUrl == "error") {
        loadingState.value = LoadingState.error;
        loadingState.refresh();
        return false;
      }
      articles.clear();
      articles.addAll(response.spotlightArticles);
      articles.refresh();
      nextUrl = response.nextUrl;
      loadingState.value = LoadingState.success;
      loadingState.refresh();
      return true;
    } catch (e) {
      error.value = e.toString();
      failedLoadToast(text: e.toString());
      loadingState.value = LoadingState.error;
      loadingState.refresh();
      return false;
    } finally {
      loadingState.value = LoadingState.idle;
      loadingState.refresh();
    }
  }

  Future<bool> next() async {
    if (loadingState.value == LoadingState.loading) return false;
    loadingState.value = LoadingState.loading;
    try {
      if (nextUrl != null && nextUrl!.isNotEmpty) {
        try {
          SpotlightResponse response = await ConnectManager().apiClient.getNextSpotlightArticles(nextUrl!);
          if (response.nextUrl != null && response.nextUrl == "error") {
            loadingState.value = LoadingState.error;
            loadingState.refresh();
            return false;
          }
          nextUrl = response.nextUrl;
          articles.addAll(response.spotlightArticles);
          articles.refresh();
          loadingState.value = nextUrl == null ? LoadingState.noMore : LoadingState.success;
          loadingState.refresh();
          return true;
        } catch (e) {
          error.value = e.toString();
          loadingState.value = LoadingState.error;
          loadingState.refresh();
          return false;
        }
      } else {
        loadingState.value = LoadingState.noMore;
        loadingState.refresh();
        return true;
      }
    } finally {
      loadingState.value = LoadingState.idle;
      loadingState.refresh();
    }
  }
}
