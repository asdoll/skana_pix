import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:skana_pix/pixiv_dart_api.dart';
import 'package:skana_pix/utils/translate.dart';
import 'package:skana_pix/utils/widgetplugin.dart';
import 'package:get/get.dart';
import '../model/worktypes.dart';
import 'avatar.dart';
import 'followbutton.dart';
import 'pixivimage.dart';
import 'userpage.dart';

class PainterCard extends StatefulWidget {
  final UserPreview user;
  final ArtworkType type;
  const PainterCard({Key? key, required this.user, this.type = ArtworkType.ALL})
      : super(key: key);

  @override
  State<PainterCard> createState() => _PainterCardState();
}

class _PainterCardState extends State<PainterCard> {
  late ArtworkType type = widget.type;
  late UserPreview _user = widget.user;
  late List<dynamic> _works = [];

  @override
  void initState() {
    super.initState();
    _works.addAll(_user.illusts);
    _works.addAll(_user.novels);
    _works.sort((a, b) => b.createDate.compareTo(a.createDate));
  }

  @override
  void didUpdateWidget(covariant PainterCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    type = widget.type;
    _user.isFollowed = widget.user.isFollowed;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        await Navigator.of(context, rootNavigator: true)
            .push(MaterialPageRoute(builder: (BuildContext context) {
          return UserPage(
            id: _user.id,
            type: type,
          );
        }));
        setState(() {});
      },
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Container(
          child: Column(
            children: [_buildPreviewSlivers(context), buildPadding(context)],
          ),
        ),
      ),
    );
  }

  _buildPreviewSlivers(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < 3; i++)
          Expanded(
            child: i < _works.length
                ? (_works[i] is Novel
                    ? buildCardNovel(context, _works[i] as Novel)
                    : buildCardIllust(context, _works[i] as Illust))
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
                  style: Theme.of(context).textTheme.titleSmall,
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
            tag: _user.avatar + this.hashCode.toString(),
            child: PainterAvatar(
              url: _user.avatar,
              id: _user.id,
              onTap: () {
                Navigator.of(context, rootNavigator: true)
                    .push(MaterialPageRoute(builder: (BuildContext context) {
                  return UserPage(
                    id: _user.id,
                    type: type,
                  );
                }));
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(child: Text(_user.name.atMost13)),
          ),
          Spacer(),
          UserFollowButton(
            liked: _user.isFollowed,
            onPressed: () async {
              try {
                var method = _user.isFollowed ? "delete" : "add";
                Res<bool> res = await followUser(_user.id.toString(), method);
                if (res.success) {
                  setState(() {
                    _user.isFollowed = !_user.isFollowed;
                  });
                } else {
                  BotToast.showText(text: "Network Error".tr);
                }
              } catch (e) {}
            },
          )
        ],
      ),
    );
  }
}
