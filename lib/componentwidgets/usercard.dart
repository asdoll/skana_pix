import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skana_pix/model/author.dart';
import 'package:skana_pix/model/illust.dart';
import 'package:skana_pix/model/novel.dart';
import 'package:skana_pix/utils/widgetplugin.dart';
import 'package:skana_pix/model/worktypes.dart';
import 'avatar.dart';
import 'followbutton.dart';
import 'pixivimage.dart';
import 'userpage.dart';

class PainterCard extends StatefulWidget {
  final UserPreview user;
  final ArtworkType type;
  const PainterCard(
      {super.key, required this.user, this.type = ArtworkType.ALL});

  @override
  State<PainterCard> createState() => _PainterCardState();
}

class _PainterCardState extends State<PainterCard> {
  late ArtworkType type = widget.type;
  late UserPreview user = widget.user;
  late List<dynamic> works = [];

  @override
  void initState() {
    super.initState();
    if (type == ArtworkType.ILLUST) {
      works.addAll(user.illusts);
    } else if (type == ArtworkType.NOVEL) {
      works.addAll(user.novels);
    } else if (type == ArtworkType.ALL) {
      works.addAll(user.illusts);
      works.addAll(user.novels);
    }
    works.sort((a, b) => b.createDate.compareTo(a.createDate));
  }

  @override
  void didUpdateWidget(covariant PainterCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    type = widget.type;
    user.isFollowed = widget.user.isFollowed;
  }

  @override
  Widget build(BuildContext context) {
    return moonListTileWidgets(
      onTap: () async {
        Get.to(() => UserPage(
              id: user.id,
              type: type,
            ));
      },
      label: Column(
        children: [_buildPreviewSlivers(context), buildPadding(context)],
      ),
    );
  }

  _buildPreviewSlivers(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        for (var i = 0; i < 3; i++)
          Expanded(
            child: i < works.length
                ? (works[i] is Novel
                    ? buildCardNovel(context, works[i] as Novel)
                    : buildCardIllust(context, works[i] as Illust))
                : Container(),
          )
      ],
    );
  }

  Widget buildCardNovel(BuildContext context, Novel novel) {
    return Container(
      child: AspectRatio(
        aspectRatio: 1.0,
        child: Stack(
          children: [
            AspectRatio(
              aspectRatio: 1.0,
              child: PixivImage(
                novel.image.squareMedium,
                fit: BoxFit.cover,
              ),
            ),
            Opacity(
              opacity: 0.4,
              child: Container(
                decoration: BoxDecoration(color: Colors.black),
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  novel.title,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ).small(),
              ),
            )
          ],
        ),
      ).rounded(8.0),
    );
  }

  Widget buildCardIllust(BuildContext context, Illust illust) {
    return AspectRatio(
      aspectRatio: 1.0,
      child: PixivImage(
        illust.images.first.squareMedium,
        fit: BoxFit.cover,
      ),
    ).rounded(8.0);
  }

  Widget buildPadding(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Hero(
            tag: user.avatar + hashCode.toString(),
            child: PainterAvatar(
              url: user.avatar,
              id: user.id,
              onTap: () {
                Get.to(() => UserPage(
                      id: user.id,
                      type: type,
                    ));
              },
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child:
                  Text(user.name, maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
          ),
          UserFollowButton(
            liked: user.isFollowed,
            id: user.id.toString(),
          )
        ],
      ),
    );
  }
}
