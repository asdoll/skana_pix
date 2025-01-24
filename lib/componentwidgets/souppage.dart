import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:html/parser.dart';
import 'package:icon_decoration/icon_decoration.dart';
import 'package:mobx/mobx.dart';
import 'package:skana_pix/componentwidgets/nullhero.dart';
import 'package:skana_pix/pixiv_dart_api.dart';
import 'package:skana_pix/utils/widgetplugin.dart';
import 'package:url_launcher/url_launcher_string.dart';

import 'avatar.dart';
import 'imagetab.dart';
import 'pixivimage.dart';
import 'package:html/dom.dart' as dom;

class SoupPage extends StatefulWidget {
  final String url;
  final SpotlightArticle? spotlight;
  final String? heroTag;

  SoupPage({Key? key, required this.url, required this.spotlight, this.heroTag})
      : super(key: key);

  @override
  _SoupPageState createState() => _SoupPageState();
}

class _SoupPageState extends State<SoupPage> {
  final SoupFetcher _soupStore = SoupFetcher();

  @override
  void initState() {
    _soupStore.fetch(widget.url);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Observer(builder: (context) {
        return NestedScrollView(
            body: buildBlocProvider(),
            headerSliverBuilder:
                (BuildContext context, bool innerBoxIsScrolled) {
              return [
                if (widget.spotlight != null)
                  SliverAppBar(
                    leading: IconButton(
                      icon: DecoratedIcon(
                        icon: Icon(Icons.arrow_back),
                        decoration:
                            IconDecoration(border: IconBorder(width: 1.5)),
                      ),
                      onPressed: () {
                        Navigator.maybePop(context);
                      },
                    ),
                    pinned: true,
                    expandedHeight: 200.0,
                    flexibleSpace: FlexibleSpaceBar(
                      titlePadding: EdgeInsets.symmetric(horizontal: 10),
                      centerTitle: true,
                      title: Stack(
                        children: <Widget>[
                          // Stroked text as border.
                          Text(
                            widget.spotlight!.pureTitle,
                            style: TextStyle(
                              foreground: Paint()
                                ..style = PaintingStyle.stroke
                                ..strokeWidth = 0.5
                                ..color = Theme.of(context).colorScheme.surface,
                            ),
                          ),
                          // Solid text as fill.
                          Text(
                            widget.spotlight!.pureTitle,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                      background: NullHero(
                        tag: widget.heroTag,
                        child: PixivImage(
                          widget.spotlight!.thumbnail,
                          fit: BoxFit.cover,
                          height: 200,
                        ),
                      ),
                    ),
                    actions: <Widget>[
                      IconButton(
                        icon: const DecoratedIcon(
                          icon: Icon(Icons.share),
                          decoration:
                              IconDecoration(border: IconBorder(width: 1.5)),
                        ),
                        onPressed: () async {
                          var url = widget.spotlight!.articleUrl;
                          await launchUrlString(url);
                        },
                      )
                    ],
                  )
                else
                  SliverAppBar()
              ];
            });
      }),
    );
  }

  Widget buildBlocProvider() {
    if (_soupStore.amWorks.isEmpty) return Container();
    return ListView.builder(
      itemBuilder: (BuildContext context, int index) {
        return Builder(builder: (context) {
          if (index == 0) {
            if (_soupStore.description.isEmpty) return Container(height: 1);
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(_soupStore.description),
              ),
            );
          }
          AmWork amWork = _soupStore.amWorks[index - 1];
          return InkWell(
            onTap: () {
              int id = int.parse(Uri.parse(amWork.arworkLink!).pathSegments[
                  Uri.parse(amWork.arworkLink!).pathSegments.length - 1]);
              Navigator.of(context, rootNavigator: true)
                  .push(MaterialPageRoute(builder: (BuildContext context) {
                return IllustPageLite(id.toString());
              }));
            },
            child: Card(
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: <Widget>[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(width: 20),
                      PainterAvatar(
                        url: amWork.userImage!,
                        id: int.parse(Uri.parse(amWork.userLink!).pathSegments[
                            Uri.parse(amWork.userLink!).pathSegments.length -
                                1]),
                        size: Size(60, 60),
                      ),
                      SizedBox(width: 15),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(trimSize(amWork.title!)),
                          SizedBox(height: 4),
                          Text(amWork.user!),
                        ],
                      ),
                    ],
                  ).paddingVertical(8),
                  PixivImage(amWork.showImage!),
                ],
              ),
            ),
          );
        });
      },
      itemCount: _soupStore.amWorks.length + 1,
    );
  }
}

class SoupFetcher {
  ObservableList<AmWork> amWorks = ObservableList();
  final dio = Dio(BaseOptions(headers: {
    HttpHeaders.acceptLanguageHeader: settings.locale.contains('zh')
        ? (settings.locale == "zh_TW" ? 'zh-TW,zh;q=0.9' : 'zh-CN,zh;q=0.9')
        : 'en-US,en;q=0.9',
    'user-agent':
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/85.0.4183.26 Safari/537.36 Edg/85.0.564.13',
    HttpHeaders.refererHeader: 'https://www.pixivision.net/zh/',
  }));

  var description = '';

  fetch(String url) async {
    try {
      if (settings.locale.contains('zh')) {
        _fetchCNTW(url);
      } else {
        _fetchEn(url);
      }
    } on Exception {
      BotToast.showText(text: "404 NOT FOUND");
    } catch (e) {
      return;
    }
  }

  _fetchEn(url) async {
    Response response = await dio.request(url);
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
    Response response = await dio.request(url);
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
