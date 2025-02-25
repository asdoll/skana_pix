import 'package:flutter/material.dart';
import 'package:moon_design/moon_design.dart';
import 'package:skana_pix/controller/list_controller.dart';
import 'package:skana_pix/controller/settings.dart';
import 'package:skana_pix/model/illust.dart';
import 'package:skana_pix/model/worktypes.dart';
import 'package:get/get.dart';
import 'package:blur/blur.dart';
import 'package:skana_pix/utils/io_extension.dart';
import 'package:skana_pix/utils/widgetplugin.dart';
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
    return Obx(() => buildInkWell(
        context,
        listController.illusts[widget.index],
        ((listController.illusts[widget.index].isR18 ||
                listController.illusts[widget.index].isR18G) &&
            settings.hideR18)));
  }

  _onLongPressSave(Illust illust) async {
    if (settings.longPressSaveConfirm) {
      final result = await alertDialog<bool>(
        context,
        "Save".tr,
        illust.title,
        [
          outlinedButton(
            label: "Cancel".tr,
            onPressed: () {
              Get.back(result: false);
            },
          ),
          filledButton(
            label: "Ok".tr,
            onPressed: () {
              Get.back(result: true);
            },
          ),
        ],
      );
      if (result != true) {
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
          ).rounded(6)
        : NullHero(
            tag: tag,
            child: PixivImage(illust.images.first.medium, fit: BoxFit.fitWidth),
          ).rounded(6);
  }

  Widget buildInkWell(BuildContext context, Illust illust, bool isR18) {
    var tooLong = (illust.height.toDouble() / illust.width.toDouble() > 3) ||
        widget.useSquare;
    var radio =
        (tooLong) ? 1.0 : illust.width.toDouble() / illust.height.toDouble();

    return moonListTileWidgets(
      noPadding: true,
        onTap: () => Get.to(
            () => ImageListViewPage(
                controllerTag: widget.controllerTag, index: widget.index),
            preventDuplicates: false),
        menuItemPadding: EdgeInsets.all(6),
        label: _buildAnimationWraper(
            context,
            Column(
              children: <Widget>[
                AspectRatio(
                    aspectRatio: radio,
                    child: Stack(
                      children: [
                        Positioned.fill(
                            child: isR18
                                ? blurWidget(_buildPic(
                                    "${widget.controllerTag}_${illust.id}",
                                    tooLong,
                                    illust))
                                : _buildPic(
                                    "${widget.controllerTag}_${illust.id}",
                                    tooLong,
                                    illust)),
                        Positioned(
                            top: 5.0,
                            right: 5.0,
                            child: Row(
                              children: [
                                if (settings.feedAIBadge && illust.isAi)
                                  _buildAIBadge().paddingOnly(right: 2),
                                _buildVisibility(illust).paddingOnly(right: 2),
                                if (isR18)
                                  _buildR18Badge().paddingOnly(right: 2),
                                if (illust.isUgoira)
                                  _buildUgoiraBadge().paddingOnly(right: 2),
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
      blurColor: Colors.grey,
      child: w,
    );
  }

  Widget _buildAIBadge() {
    return Padding(
      padding: EdgeInsets.all(1.0),
      child: Container(
        decoration: const BoxDecoration(
          color: Color.fromRGBO(0, 0, 0, 0.4),
          borderRadius: BorderRadius.all(Radius.circular(4.0)),
        ),
        child: const Padding(
          padding: EdgeInsets.symmetric(vertical: 2.0, horizontal: 4.0),
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
      padding: EdgeInsets.all(1.0),
      child: Container(
        decoration: const BoxDecoration(
          color: Color.fromRGBO(0, 0, 0, 0.4),
          borderRadius: BorderRadius.all(Radius.circular(4.0)),
        ),
        child: const Padding(
          padding: EdgeInsets.symmetric(vertical: 2.0, horizontal: 4.0),
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
      padding: EdgeInsets.all(1.0),
      child: Container(
        decoration: const BoxDecoration(
          color: Color.fromRGBO(0, 0, 0, 0.4),
          borderRadius: BorderRadius.all(Radius.circular(4.0)),
        ),
        child: const Padding(
          padding: EdgeInsets.symmetric(vertical: 2.0, horizontal: 4.0),
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
        _buildLongPressToSaveHint(context, illust);
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

  _buildLongPressToSaveHint(BuildContext context, Illust illust) async {
    if (GetPlatform.isIOS) {
      if (settings.firstLongPressSave) {
        settings.set("firstLongPressSave", false);
        await alertDialog<void>(context, "长按保存".tr, '长按卡片将会保存插画到相册'.tr, [
          filledButton(
            label: "Ok".tr,
            onPressed: () {
              Get.back();
            },
          )
        ]);
      }
    }
    _onLongPressSave(illust);
  }

  Widget _buildBottom(BuildContext context, Illust illust) {
    return Stack(
      children: <Widget>[
        Padding(
          padding:
              const EdgeInsets.only(left: 8.0, right: 36.0, top: 8, bottom: 2),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              illust.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              strutStyle: const StrutStyle(forceStrutHeight: true, leading: 0),
            ).subHeader().paddingOnly(bottom: 4),
            Text(
              illust.author.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  color:
                      context.moonTheme?.menuItemTheme.colors.contentTextColor),
              strutStyle: const StrutStyle(forceStrutHeight: true, leading: 0),
            ).small()
          ]),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: StarIcon(id: illust.id.toString(), type: widget.type, liked: illust.isBookmarked)
              .paddingOnly(right: 2, top: 8),
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
          padding: EdgeInsets.all(1.0),
          child: Container(
            decoration: const BoxDecoration(
              color: Color.fromRGBO(0, 0, 0, 0.4),
              borderRadius: BorderRadius.all(Radius.circular(4.0)),
            ),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 2.0, horizontal: 4.0),
              child: cardText(illust),
            ),
          ),
        ),
      ),
    );
  }
}
