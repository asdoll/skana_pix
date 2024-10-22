import 'dart:ui';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:skana_pix/componentwidgets/loading.dart';
import 'package:skana_pix/pixiv_dart_api.dart';
import 'package:skana_pix/utils/navigation.dart';
import 'package:skana_pix/utils/translate.dart';
import 'package:blur/blur.dart';

import '../view/defaults.dart';
import 'imagelist.dart';
import 'nullhero.dart';
import 'pixivimage.dart';
import 'staricon.dart';

typedef UpdateFavoriteFunc = void Function(bool v);

class IllustCard extends StatefulWidget {
  const IllustCard(this.illusts, this.showMangaBadage,
      {this.initialPage = 0, this.type = 0, super.key});

  final showMangaBadage;

  final List<Illust> illusts;

  static Map<String, UpdateFavoriteFunc> favoriteCallbacks = {};

  final int initialPage;

  final int type;

  @override
  _IllustCardState createState() => _IllustCardState();
}

class _IllustCardState extends State<IllustCard> {
  late List<Illust> illusts;
  bool isBookmarking = false;
  late String tag;
  late int page = 0;
  Illust get illust => illusts[page];
  String get nextUrl =>
      illusts.length < 2 ? "end" : (widget.type == 0 ? "illust" : "manga");

  @override
  void initState() {
    illusts = widget.illusts;
    page = widget.initialPage;
    tag = hashCode.toString();
    IllustCard.favoriteCallbacks[illust.id.toString()] = (v) {
      setState(() {
        illust.isBookmarked = v;
      });
    };
    super.initState();
  }

  @override
  void dispose() {
    IllustCard.favoriteCallbacks.remove(illust.id.toString());
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant IllustCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    illusts = widget.illusts;
    page = widget.initialPage;
  }

  @override
  Widget build(BuildContext context) {
    if ((illust.isR18 || illust.isR18G) && settings.hideR18) {
      return buildR18InkWell(context);
    }

    return buildInkWell(context);
  }

  _onLongPressSave() async {
    if (settings.longPressSaveConfirm) {
      final result = await showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("Save".i18n),
              content: Text(illust.title),
              actions: <Widget>[
                TextButton(
                  child: Text("Cancel".i18n),
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                ),
                TextButton(
                  child: Text("Ok".i18n),
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                ),
              ],
            );
          });
      if (!result) {
        return;
      }
    }
    saveImage(illust);
    // if (userSetting.starAfterSave && (store.state == 0)) {
    //   store.star(
    //       restrict: userSetting.defaultPrivateLike ? "private" : "public");
    // }
  }

  Future _buildTap(BuildContext context) {
    return context.to(() => ImageListPage(
          illust,
          illusts: illusts,
          initialPage: page,
          nextUrl: nextUrl,
        ));
  }

  Widget cardText() {
    if (illust.type == "manga" && widget.showMangaBadage) {
      return Text(
        illust.type.i18n,
        style: TextStyle(color: Colors.white),
      );
    }
    if (illust.images.length > 1) {
      return Text(
        illust.images.length.toString(),
        style: TextStyle(color: Colors.white),
      );
    }
    return Text('');
  }

  Widget _buildPic(String tag, bool tooLong) {
    return tooLong
        ? NullHero(
            tag: tag,
            child: PixivImage(illust.images.first.squareMedium,
                fit: BoxFit.fitWidth),
          )
        : NullHero(
            tag: tag,
            child: PixivImage(illust.images.first.medium, fit: BoxFit.fitWidth),
          );
  }

  Widget buildInkWell(BuildContext context) {
    var tooLong = illust.height.toDouble() / illust.width.toDouble() > 3;
    var radio =
        (tooLong) ? 1.0 : illust.width.toDouble() / illust.height.toDouble();
    return Card(
        margin: const EdgeInsets.all(8.0),
        clipBehavior: Clip.antiAlias,
        color: Theme.of(context).colorScheme.surface,
        child: _buildAnimationWraper(
          context,
          Column(
            children: <Widget>[
              AspectRatio(
                  aspectRatio: radio,
                  child: Stack(
                    children: [
                      Positioned.fill(child: _buildPic(tag, tooLong)),
                      Positioned(
                          top: 5.0,
                          right: 5.0,
                          child: Row(
                            children: [
                              if (settings.feedAIBadge && illust.isAi)
                                _buildAIBadge(),
                              _buildVisibility()
                            ],
                          )),
                    ],
                  )),
              _buildBottom(context),
            ],
          ),
        ));
  }

  Widget buildR18InkWell(BuildContext context) {
    var tooLong = illust.height.toDouble() / illust.width.toDouble() > 3;
    var radio =
        (tooLong) ? 1.0 : illust.width.toDouble() / illust.height.toDouble();
    return Card(
        margin: const EdgeInsets.all(8.0),
        clipBehavior: Clip.antiAlias,
        color: Theme.of(context).colorScheme.surface,
        child: _buildAnimationWraper(
          context,
          Column(
            children: <Widget>[
              AspectRatio(
                  aspectRatio: radio,
                  child: Stack(
                    children: [
                      Positioned.fill(
                          child: blurWidget(_buildPic(tag, tooLong))),
                      Positioned(
                          top: 5.0,
                          right: 5.0,
                          child: Row(
                            children: [
                              if (settings.feedAIBadge && illust.isAi)
                                _buildAIBadge(),
                              _buildR18Badge()
                            ],
                          )),
                    ],
                  )),
              _buildBottom(context),
            ],
          ),
        ));
  }

  Widget blurWidget(Widget w) {
    return Blur(
      blur: 5,
      blurColor: Colors.grey,
      child: w,
    );
  }

  Widget _buildAIBadge() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.all(Radius.circular(4.0)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 2.0),
        child: Text(
          "AI",
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildR18Badge() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.all(Radius.circular(4.0)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 2.0),
        child: Text(
          "R18",
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildAnimationWraper(BuildContext context, Widget child) {
    return InkWell(
      onLongPress: () {
        _buildLongPressToSaveHint();
      },
      onTap: () {
        _buildInkTap(context, tag);
      },
      child: child,
    );
  }

  _buildLongPressToSaveHint() async {
    if (DynamicData.isIOS) {
      if (settings.firstLongPressSave) {
        settings.set("firstLongPressSave", false);
        await showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text('长按保存'),
                content: Text('长按卡片将会保存插画到相册'),
                actions: <Widget>[
                  TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text('Ok'.i18n))
                ],
              );
            });
      }
    }
    _onLongPressSave();
  }

  Future _buildInkTap(BuildContext context, String heroTag) {
    return PersistentNavBarNavigator.pushNewScreen(
      context,
      screen: ImageListPage(illust,
          initialPage: page, illusts: illusts, nextUrl: nextUrl),
      withNavBar: false, // OPTIONAL VALUE. True by default.
      pageTransitionAnimation: PageTransitionAnimation.scale,
      // customPageRoute: AppPageRoute(
      //     builder: (context) =>
      //         ImagePage(illust.images.map((e) => e.large).toList())),
    );
  }

  Widget _buildBottom(BuildContext context) {
    return Container(
      child: Stack(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(
                left: 8.0, right: 36.0, top: 4, bottom: 4),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                illust.title,
                maxLines: 1,
                overflow: TextOverflow.clip,
                style: Theme.of(context).textTheme.bodyMedium,
                strutStyle:
                    const StrutStyle(forceStrutHeight: true, leading: 0),
              ),
              Text(
                illust.author.name,
                maxLines: 1,
                overflow: TextOverflow.clip,
                style: Theme.of(context).textTheme.bodySmall,
                strutStyle:
                    const StrutStyle(forceStrutHeight: true, leading: 0),
              )
            ]),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              child: StarIcon(state: likeState()),
              onTap: likes,
              // onLongPress: () async {
              //   final result = await showModalBottomSheet(
              //     context: context,
              //     clipBehavior: Clip.hardEdge,
              //     shape: RoundedRectangleBorder(
              //       borderRadius:
              //           BorderRadius.vertical(top: Radius.circular(16)),
              //     ),
              //     constraints: BoxConstraints.expand(
              //         height: MediaQuery.of(context).size.height * .618),
              //     isScrollControlled: true,
              //     builder: (_) => TagForIllustPage(id: illust.id),
              //   );
              //   if (result?.isNotEmpty ?? false) {
              //     LPrinter.d(result);
              //     String restrict = result['restrict'];
              //     List<String>? tags = result['tags'];
              //     store.star(restrict: restrict, tags: tags, force: true);
              //   }
              // },
            ),
          )
        ],
      ),
    );
  }

  int likeState() {
    if (isBookmarking) {
      return 1;
    }
    if (illust.isBookmarked) {
      return 2;
    }
    return 0;
  }

  void likes([String type = "public"]) async {
    if (isBookmarking) return;
    setState(() {
      isBookmarking = true;
    });
    var method = illust.isBookmarked ? "delete" : "add";
    var res = await ConnectManager()
        .apiClient
        .addBookmark(illust.id.toString(), method, type);
    if (res.error) {
      if (mounted) {
        BotToast.showText(text: "Network Error".i18n);
      }
    } else {
      illust.isBookmarked = !illust.isBookmarked;
    }
    setState(() {
      isBookmarking = false;
    });
  }

  Widget _buildVisibility() {
    return Visibility(
      visible: ((illust.type == "manga") && (widget.showMangaBadage)) ||
          illust.images.length > 1,
      child: Align(
        alignment: Alignment.topRight,
        child: Padding(
          padding: EdgeInsets.all(4.0),
          child: Container(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 2.0, horizontal: 2.0),
              child: cardText(),
            ),
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.all(Radius.circular(4.0)),
            ),
          ),
        ),
      ),
    );
  }
}

class IllustStoreWidget extends StatefulWidget {
  final String id;
  const IllustStoreWidget(this.id, {super.key});
  @override
  _IllustStoreWidgetState createState() => _IllustStoreWidgetState();
}

class _IllustStoreWidgetState extends LoadingState<IllustStoreWidget, Illust> {
  @override
  Widget buildContent(BuildContext context, Illust data) {
    return IllustCard([data], false);
  }

  @override
  Future<Res<Illust>> loadData() {
    return getIllustByID(widget.id);
  }
}
