import 'package:flutter/material.dart' show InkWell;
import 'package:skana_pix/controller/list_controller.dart';
import 'package:skana_pix/model/worktypes.dart';
import 'package:skana_pix/pixiv_dart_api.dart';
import 'package:get/get.dart';
import 'package:blur/blur.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import '../controller/defaults.dart';
import '../view/imageview/imagelistview.dart';
import 'nullhero.dart';
import 'pixivimage.dart';
import 'staricon.dart';

class IllustCard extends StatefulWidget {
  const IllustCard(
      {this.index = 0,
      this.type = ArtworkType.ILLUST,
      this.useSquare = false,
      required this.controllerTag,
      this.showMangaBadage = true,
      super.key});

  final bool showMangaBadage;

  final bool useSquare;

  final int index;

  final ArtworkType type;

  final String controllerTag;

  @override
  State<IllustCard> createState() => _IllustCardState();
}

class _IllustCardState extends State<IllustCard> {
  late ListIllustController listController;

  @override
  Widget build(BuildContext context) {
    listController = Get.find<ListIllustController>(tag: widget.controllerTag);
    return Obx(() {
      if ((listController.illusts[widget.index].isR18 ||
              listController.illusts[widget.index].isR18G) &&
          settings.hideR18) {
        return buildR18InkWell(context, listController.illusts[widget.index]);
      }

      return buildInkWell(context, listController.illusts[widget.index]);
    });
  }

  _onLongPressSave(Illust illust) async {
    if (settings.longPressSaveConfirm) {
      final result = await showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("Save".tr),
              content: Text(illust.title),
              actions: <Widget>[
                TextButton(
                  child: Text("Cancel".tr),
                  onPressed: () {
                    Get.back(result: false);
                  },
                ),
                TextButton(
                  child: Text("Ok".tr),
                  onPressed: () {
                    Get.back(result: true);
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
  }

  Widget cardText(Illust illust) {
    if (illust.type == "manga" && widget.showMangaBadage) {
      return Text(
        illust.type.tr,
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

  Widget _buildPic(String tag, bool tooLong, Illust illust) {
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

  Widget buildInkWell(BuildContext context, Illust illust) {
    var tooLong = (illust.height.toDouble() / illust.width.toDouble() > 3) ||
        widget.useSquare;
    var radio =
        (tooLong) ? 1.0 : illust.width.toDouble() / illust.height.toDouble();
    return Card(
        padding: const EdgeInsets.all(8.0),
        clipBehavior: Clip.antiAlias,
        child: _buildAnimationWraper(
            context,
            Column(
              children: <Widget>[
                AspectRatio(
                    aspectRatio: radio,
                    child: Stack(
                      children: [
                        Positioned.fill(
                            child: _buildPic(
                                "${widget.controllerTag}_${illust.id}",
                                tooLong,
                                illust)),
                        Positioned(
                            top: 5.0,
                            right: 5.0,
                            child: Row(
                              children: [
                                if (settings.feedAIBadge && illust.isAi)
                                  _buildAIBadge(),
                                _buildVisibility(illust),
                                if (illust.isUgoira) _buildUgoiraBadge(),
                              ],
                            )),
                      ],
                    )),
                _buildBottom(context, illust),
              ],
            ),
            illust));
  }

  Widget buildR18InkWell(BuildContext context, Illust illust) {
    var tooLong = illust.height.toDouble() / illust.width.toDouble() > 3;
    var radio =
        (tooLong) ? 1.0 : illust.width.toDouble() / illust.height.toDouble();
    return Card(
        padding: const EdgeInsets.all(8.0),
        clipBehavior: Clip.antiAlias,
        child: _buildAnimationWraper(
            context,
            Column(
              children: <Widget>[
                AspectRatio(
                    aspectRatio: radio,
                    child: Stack(
                      children: [
                        Positioned.fill(
                            child: blurWidget(_buildPic(
                                "${widget.controllerTag}_${illust.id}",
                                tooLong,
                                illust))),
                        Positioned(
                            top: 5.0,
                            right: 5.0,
                            child: Row(
                              children: [
                                if (settings.feedAIBadge && illust.isAi)
                                  _buildAIBadge(),
                                _buildR18Badge(),
                                if (illust.isUgoira) _buildUgoiraBadge(),
                              ],
                            )),
                      ],
                    )),
                _buildBottom(context, illust),
              ],
            ),
            illust));
  }

  Widget blurWidget(Widget w) {
    return Blur(
      blur: 5,
      blurColor: Colors.gray,
      child: w,
    );
  }

  Widget _buildAIBadge() {
    return Padding(
      padding: EdgeInsets.all(4.0),
      child: Container(
        decoration: const BoxDecoration(
          color: Color.fromRGBO(255, 255, 255, 0.2),
          borderRadius: BorderRadius.all(Radius.circular(4.0)),
        ),
        child: const Padding(
          padding: EdgeInsets.symmetric(vertical: 2.0, horizontal: 2.0),
          child: Text(
            "AI",
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _buildR18Badge() {
    return Padding(
      padding: EdgeInsets.all(4.0),
      child: Container(
        decoration: const BoxDecoration(
          color: Color.fromRGBO(255, 255, 255, 0.2),
          borderRadius: BorderRadius.all(Radius.circular(4.0)),
        ),
        child: const Padding(
          padding: EdgeInsets.symmetric(vertical: 2.0, horizontal: 2.0),
          child: Text(
            "R18",
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _buildUgoiraBadge() {
    return Padding(
      padding: EdgeInsets.all(4.0),
      child: Container(
        decoration: const BoxDecoration(
          color: Color.fromRGBO(255, 255, 255, 0.2),
          borderRadius: BorderRadius.all(Radius.circular(4.0)),
        ),
        child: const Padding(
          padding: EdgeInsets.symmetric(vertical: 2.0, horizontal: 2.0),
          child: Text(
            "ugoira",
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimationWraper(
      BuildContext context, Widget child, Illust illust) {
    return InkWell(
      onLongPress: () {
        _buildLongPressToSaveHint(illust);
      },
      onTap: () {
        Get.to(
            () => ImageListViewPage(
                controllerTag: widget.controllerTag, index: widget.index),
            preventDuplicates: false);
      },
      child: child,
    );
  }

  _buildLongPressToSaveHint(Illust illust) async {
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
                        Get.back();
                      },
                      child: Text('Ok'.tr))
                ],
              );
            });
      }
    }
    _onLongPressSave(illust);
  }

  Widget _buildBottom(BuildContext context, Illust illust) {
    return Stack(
      children: <Widget>[
        Padding(
          padding:
              const EdgeInsets.only(left: 8.0, right: 36.0, top: 4, bottom: 4),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              illust.title,
              maxLines: 1,
              overflow: TextOverflow.clip,
              style: Theme.of(context).typography.textSmall,
              strutStyle: const StrutStyle(forceStrutHeight: true, leading: 0),
            ),
            Text(
              illust.author.name,
              maxLines: 1,
              overflow: TextOverflow.clip,
              style: Theme.of(context).typography.textSmall,
              strutStyle: const StrutStyle(forceStrutHeight: true, leading: 0),
            )
          ]),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: StarIcon(id: illust.id.toString(), type: widget.type),
        )
      ],
    );
  }

  Widget _buildVisibility(Illust illust) {
    return Visibility(
      visible: ((illust.type == "manga") && (widget.showMangaBadage)) ||
          illust.images.length > 1,
      child: Align(
        alignment: Alignment.topRight,
        child: Padding(
          padding: EdgeInsets.all(4.0),
          child: Container(
            decoration: const BoxDecoration(
              color: Color.fromRGBO(255, 255, 255, 0.2),
              borderRadius: BorderRadius.all(Radius.circular(4.0)),
            ),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 2.0, horizontal: 2.0),
              child: cardText(illust),
            ),
          ),
        ),
      ),
    );
  }
}
