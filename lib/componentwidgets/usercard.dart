import 'package:flutter/material.dart' show InkWell;
import 'package:get/get.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:skana_pix/pixiv_dart_api.dart';
import 'package:skana_pix/utils/translate.dart';
import 'package:skana_pix/utils/widgetplugin.dart';
import '../model/worktypes.dart';
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
    return InkWell(
      onTap: () async {
        Get.to(() => UserPage(
              id: user.id,
              type: type,
            ));
      },
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [_buildPreviewSlivers(context), buildPadding(context)],
        ),
      ),
    );
  }

  _buildPreviewSlivers(BuildContext context) {
    return Row(
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
      padding: const EdgeInsets.all(4.0),
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
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  novel.title,
                  style: Theme.of(context).typography.h3,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            )
          ],
        ),
      ).rounded(8.0),
    );
  }

  Widget buildCardIllust(BuildContext context, Illust illust) {
    return Container(
      padding: const EdgeInsets.all(4.0),
      child: AspectRatio(
        aspectRatio: 1.0,
        child: PixivImage(
          illust.images.first.squareMedium,
          fit: BoxFit.cover,
        ),
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
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(child: Text(user.name.atMost13)),
          ),
          Spacer(),
          UserFollowButton(
            liked: user.isFollowed,
            id: user.id.toString(),
          )
        ],
      ),
    );
  }
}
