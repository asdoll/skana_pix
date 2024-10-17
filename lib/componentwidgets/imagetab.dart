import 'package:flutter/material.dart';
import 'package:skana_pix/componentwidgets/loading.dart';
import 'package:skana_pix/pixiv_dart_api.dart';

class IllustCard extends StatefulWidget {
  const IllustCard(this.illust, {this.nextPage, this.previousPage, super.key});

  final Illust illust;

  final void Function()? nextPage;

  final void Function()? previousPage;

  @override
  _IllustCardState createState() => _IllustCardState();
}

class _IllustCardState extends State<IllustCard> {
  late IllustStore store;
  late List<IllustStore>? iStores;
  late String tag;
  late LightingStore _lightingStore;

  @override
  void initState() {
    store = widget.store;
    iStores = widget.iStores;
    _lightingStore = widget.lightingStore;
    tag = this.hashCode.toString();
    super.initState();
  }

  @override
  void didUpdateWidget(covariant IllustCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    store = widget.store;
    iStores = widget.iStores;
    _lightingStore = widget.lightingStore;
  }

  @override
  Widget build(BuildContext context) {
    if (userSetting.hIsNotAllow)
      for (int i = 0; i < store.illusts!.tags.length; i++) {
        if (store.illusts!.tags[i].name.startsWith('R-18'))
          return InkWell(
            onTap: () => _buildTap(context),
            onLongPress: () => _onLongPressSave(),
            child: Card(
              margin: EdgeInsets.all(8.0),
              elevation: 8.0,
              clipBehavior: Clip.antiAlias,
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8.0))),
              child: Image.asset('assets/images/h.jpg'),
            ),
          );
      }
    return buildInkWell(context);
  }

  _onLongPressSave() async {
    if (userSetting.longPressSaveConfirm) {
      final result = await showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text(I18n.of(context).save),
              content: Text(store.illusts?.title ?? ""),
              actions: <Widget>[
                TextButton(
                  child: Text(I18n.of(context).cancel),
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                ),
                TextButton(
                  child: Text(I18n.of(context).ok),
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
    saveStore.saveImage(store.illusts!);
    if (userSetting.starAfterSave && (store.state == 0)) {
      store.star(
          restrict: userSetting.defaultPrivateLike ? "private" : "public");
    }
  }

  Future _buildTap(BuildContext context) {
    return Navigator.of(context, rootNavigator: true)
        .push(MaterialPageRoute(builder: (_) {
      return PictureListPage(
        iStores: iStores!,
        store: store,
        lightingStore: _lightingStore,
        heroString: tag,
      );
    }));
  }

  Widget cardText() {
    if (store.illusts!.type != "illust") {
      return Text(
        store.illusts!.type,
        style: TextStyle(color: Colors.white),
      );
    }
    if (store.illusts!.metaPages.isNotEmpty) {
      return Text(
        store.illusts!.metaPages.length.toString(),
        style: TextStyle(color: Colors.white),
      );
    }
    return Text('');
  }

  Widget _buildPic(String tag, bool tooLong) {
    return tooLong
        ? NullHero(
            tag: tag,
            child: PixivImage(store.illusts!.imageUrls.squareMedium,
                fit: BoxFit.fitWidth),
          )
        : NullHero(
            tag: tag,
            child:
                PixivImage(store.illusts!.feedPreviewUrl, fit: BoxFit.fitWidth),
          );
  }

  Widget buildInkWell(BuildContext context) {
    var tooLong =
        store.illusts!.height.toDouble() / store.illusts!.width.toDouble() > 3;
    var radio = (tooLong)
        ? 1.0
        : store.illusts!.width.toDouble() / store.illusts!.height.toDouble();
    return Card(
        margin: EdgeInsets.all(8.0),
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
                              if (userSetting.feedAIBadge &&
                                  store.illusts!.illustAIType == 2)
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
    if (Platform.isIOS) {
      final pref = await SharedPreferences.getInstance();
      final firstLongPress = await pref.getBool("first_long_press") ?? true;
      if (firstLongPress) {
        await pref.setBool("first_long_press", false);
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
                      child: Text(I18n.of(context).ok))
                ],
              );
            });
      }
    }
    _onLongPressSave();
  }

  Future _buildInkTap(BuildContext context, String heroTag) {
    return Navigator.of(context, rootNavigator: true)
        .push(MaterialPageRoute(builder: (_) {
      if (iStores != null) {
        return PictureListPage(
          heroString: heroTag,
          store: store,
          lightingStore: _lightingStore,
          iStores: iStores!,
        );
      }
      return IllustLightingPage(
        id: store.illusts!.id,
        heroString: heroTag,
        store: store,
      );
    }));
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
                store.illusts!.title,
                maxLines: 1,
                overflow: TextOverflow.clip,
                style: Theme.of(context).textTheme.bodyMedium,
                strutStyle: StrutStyle(forceStrutHeight: true, leading: 0),
              ),
              Text(
                store.illusts!.user.name,
                maxLines: 1,
                overflow: TextOverflow.clip,
                style: Theme.of(context).textTheme.bodySmall,
                strutStyle: StrutStyle(forceStrutHeight: true, leading: 0),
              )
            ]),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              child: Observer(builder: (_) {
                return StarIcon(
                  state: store.state,
                );
              }),
              onTap: () async {
                if (userSetting.saveAfterStar && (store.state == 0)) {
                  saveStore.saveImage(store.illusts!);
                }
                store.star(
                    restrict:
                        userSetting.defaultPrivateLike ? "private" : "public");
                if (userSetting.followAfterStar) {
                  bool success = await store.followAfterStar();
                  if (success) {
                    BotToast.showText(
                        text:
                            "${store.illusts!.user.name} ${I18n.of(context).followed}");
                  }
                }
              },
              onLongPress: () async {
                final result = await showModalBottomSheet(
                  context: context,
                  clipBehavior: Clip.hardEdge,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  constraints: BoxConstraints.expand(
                      height: MediaQuery.of(context).size.height * .618),
                  isScrollControlled: true,
                  builder: (_) => TagForIllustPage(id: store.illusts!.id),
                );
                if (result?.isNotEmpty ?? false) {
                  LPrinter.d(result);
                  String restrict = result['restrict'];
                  List<String>? tags = result['tags'];
                  store.star(restrict: restrict, tags: tags, force: true);
                }
              },
            ),
          )
        ],
      ),
    );
  }

  Widget _buildVisibility() {
    return Visibility(
      visible: store.illusts!.type != "illust" ||
          store.illusts!.metaPages.isNotEmpty,
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
    return IllustCard(data);
  }

  @override
  Future<Res<Illust>> loadData() {
    return ConnectManager().apiClient.getIllustByID(widget.id);
  }
}
