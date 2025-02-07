import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart'
    show
        CollapseMode,
        FlexibleSpaceBar,
        InkWell,
        PopupMenuButton,
        PopupMenuItem,
        SelectionArea;
import 'package:flutter/services.dart';
import 'package:icon_decoration/icon_decoration.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:skana_pix/componentwidgets/userdetail.dart';
import 'package:skana_pix/controller/mini_controllers.dart';
import 'package:skana_pix/view/userview/userworks.dart';
import 'package:skana_pix/controller/caches.dart';
import 'package:skana_pix/controller/like_controller.dart';
import 'package:skana_pix/model/worktypes.dart';
import 'package:skana_pix/pixiv_dart_api.dart';
import 'package:get/get.dart';
import 'package:skana_pix/utils/leaders.dart';
import 'package:skana_pix/utils/widgetplugin.dart';

import 'avatar.dart';
import 'backarea.dart';
import 'followbutton.dart';
import '../view/userview/followlist.dart';
import 'nullhero.dart';
import '../view/bookmarkspage.dart';

class UserPage extends StatefulWidget {
  final ArtworkType type;
  final String? heroTag;
  final int id;
  final bool isMe;
  const UserPage(
      {super.key,
      required this.id,
      this.heroTag,
      this.type = ArtworkType.ALL,
      this.isMe = false});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> with TickerProviderStateMixin {
  late ScrollController _scrollController;
  late MTab mTab;
  bool backToTopVisible = false;
  UserDetails? userDetail;
  bool isMuted = false;
  bool isError = false;
  ArtworkType get type =>
      widget.type == ArtworkType.ALL ? ArtworkType.ILLUST : widget.type;

  String restrict = 'public';

  @override
  void initState() {
    mTab = Get.put(MTab(), tag: "userpage_${widget.id}");
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      if (_scrollController.hasClients) {
        if (_scrollController.offset > 100) {
          if (!backToTopVisible) {
            setState(() {
              backToTopVisible = true;
            });
          }
        } else {
          if (backToTopVisible) {
            setState(() {
              backToTopVisible = false;
            });
          }
        }
      }
    });
    super.initState();
    firstLoad();
  }

  @override
  void dispose() {
    Get.delete<MTab>(tag: "userpage_${widget.id}");
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isMuted) {
      return Scaffold(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text('X_X'),
              Text('${widget.id}'),
              PrimaryButton(
                  onPressed: () {
                    settings.removeBlockedUsers([widget.id.toString()]);
                    setState(() {
                      isMuted = false;
                    });
                  },
                  child: Text("Unblock".tr)),
            ],
          ),
        ),
      );
    }

    if (isError && userDetail == null) {
      return Scaffold(
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Network Error".tr,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: PrimaryButton(
                  onPressed: () {
                    firstLoad();
                  },
                  child: Text("Retry".tr),
                ),
              )
            ],
          ),
        ),
      );
    }
    if (userDetail == null) {
      return Scaffold(
        child: Center(child: CircularProgressIndicator(size: 48)),
      );
    }
    return _buildBody(context);
  }

  Widget _buildBody(BuildContext context) {
    return Scaffold(
      child: NestedScrollView(
        controller: _scrollController,
        body: Obx(
          () => (mTab.index.value == 0)
              ? WorksPage(
                  id: userDetail!.id,
                  type: type,
                  noScroll: true,
                )
              : (mTab.index.value == 1)
                  ? BookmarksPage(
                      id: userDetail!.id,
                      type: type,
                      noScroll: true,
                    )
                  : UserDetailPage(userDetail!),
        ).paddingTop(102 + MediaQuery.of(context).padding.top),
        headerSliverBuilder: (BuildContext context, bool? innerBoxIsScrolled) {
          return _HeaderSlivers(innerBoxIsScrolled, context);
        },
      ),
    );
  }

  List<Widget> _HeaderSlivers(bool? innerBoxIsScrolled, BuildContext context) {
    return [
      SliverOverlapAbsorber(
        handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
        sliver: SliverAppBar(
            pinned: true,
            elevation: 0.0,
            forceElevated: innerBoxIsScrolled ?? false,
            expandedHeight: userDetail?.backgroundImage != null
                ? MediaQuery.of(context).size.width / 2 +
                    205 -
                    MediaQuery.of(context).padding.top
                : 300,
            leading: CommonBackArea(),
            actions: <Widget>[
              Builder(builder: (context) {
                return GhostButton(
                    child: const DecoratedIcon(
                      icon: Icon(Icons.share),
                      decoration:
                          IconDecoration(border: IconBorder(width: 1.5)),
                    ),
                    onPressed: () {
                      final box = context.findRenderObject() as RenderBox?;
                      final pos = box != null
                          ? box.localToGlobal(Offset.zero) & box.size
                          : null;
                      Share.share('https://www.pixiv.net/users/${widget.id}',
                          sharePositionOrigin: pos);
                    });
              }),
              _buildPopMenu(context)
            ],
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: Stack(
                children: <Widget>[
                  _buildBackground(context),
                  _buildFakeBg(context),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        _buildHeader(context),
                        Column(
                          children: <Widget>[
                            _buildNameFollow(context),
                            _buildComment(context),
                            const Text(
                              " ",
                            ).h3(),
                          ],
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            bottom: PreferredSize(
                preferredSize: Size.fromHeight(48),
                child: Obx(() => TabList(
                      index: mTab.index.value,
                      children: [
                        TabButton(
                          onPressed: () {
                            if (mTab.index.value == 0) {
                              _scrollController.position.animateTo(0,
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut);
                            }
                            mTab.index.value = 0;
                          },
                          child: Text(
                            "Artworks".tr,
                          ),
                        ),
                        TabButton(
                          onPressed: () {
                            if (mTab.index.value == 1) {
                              _scrollController.position.animateTo(0,
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut);
                            }
                            mTab.index.value = 1;
                          },
                          child: Text(
                            "Bookmarks".tr,
                          ),
                        ),
                        TabButton(
                          onPressed: () {
                            if (mTab.index.value == 2) {
                              _scrollController.position.animateTo(0,
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut);
                            }
                            mTab.index.value = 2;
                          },
                          child: Text(
                            "Details".tr,
                          ),
                        ),
                      ],
                    )))),
      ),
    ];
  }

  //为什么会需要这段？因为外部Column无法使子元素贴紧，子元素之间在真机上总是有spacing，所以底部又需要一个cardColor来填充
  Widget _buildFakeBg(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            height: 55,
          ),
          Column(
            children: <Widget>[
              _buildFakeNameFollow(context),
              Container(
                height: 60,
              ),
              const Text(
                " ",
              ).h3()
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBackground(BuildContext context) {
    return SizedBox(
        width: MediaQuery.of(context).size.width,
        height: userDetail?.backgroundImage != null
            ? MediaQuery.of(context).size.width / 2
            : MediaQuery.of(context).padding.top + 90,
        child: userDetail != null
            ? userDetail!.backgroundImage != null
                ? InkWell(
                    onLongPress: () {
                      showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Text("Save".tr)
                                  .withAlign(Alignment.centerLeft),
                              content: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: CachedNetworkImage(
                                  imageUrl: userDetail!.backgroundImage!,
                                  fit: BoxFit.cover,
                                  cacheManager: imagesCacheManager,
                                ),
                              ),
                              actions: [
                                OutlineButton(
                                    onPressed: () async {
                                      Navigator.of(context).pop();
                                    },
                                    child: Text("Cancel".tr)),
                                PrimaryButton(
                                    onPressed: () async {
                                      Navigator.of(context).pop();
                                      await _saveUserBg(context,
                                          userDetail!.backgroundImage!);
                                    },
                                    child: Text("Ok".tr)),
                              ],
                            );
                          });
                    },
                    child: CachedNetworkImage(
                      imageUrl: userDetail!.backgroundImage!,
                      fit: BoxFit.fitWidth,
                      cacheManager: imagesCacheManager,
                    ),
                  )
                : Container(
                    color: Theme.of(context).colorScheme.secondary,
                  )
            : Container());
  }

  PopupMenuButton<int> _buildPopMenu(BuildContext context) {
    return PopupMenuButton<int>(
      icon: const DecoratedIcon(
        icon: Icon(Icons.more_vert),
        decoration: IconDecoration(border: IconBorder(width: 1.5)),
      ),
      onSelected: (index) async {
        switch (index) {
          case 0:
            if (widget.isMe) {
              Leader.showToast("You can't follow yourself".tr);
              return;
            }
            followUser(userDetail!.id.toString(), "add", "private");

            break;
          case 1:
            {
              final result = await showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text('${"Block User".tr}?')
                          .withAlign(Alignment.centerLeft),
                      actions: <Widget>[
                        OutlineButton(
                          child: Text("Cancel".tr),
                          onPressed: () {
                            Get.back();
                          },
                        ),
                        PrimaryButton(
                          child: Text("Ok".tr),
                          onPressed: () {
                            Get.back(result: "OK");
                          },
                        ),
                      ],
                    );
                  });
              if (result == "OK") {
                settings.addBlockedUsers([userDetail!.name]);
                setState(() {
                  isMuted = true;
                });
                Get.back();
              }
            }
            break;
          case 2:
            {
              Clipboard.setData(ClipboardData(
                  text: 'painter:${userDetail?.name ?? ''}\npid:${widget.id}'));
              Leader.showToast("Copied to clipboard".tr);
              break;
            }
          default:
        }
      },
      itemBuilder: (context) {
        return [
          if (!userDetail!.isFollowed)
            PopupMenuItem<int>(
              value: 0,
              child: Text("Follow privately".tr),
            ),
          PopupMenuItem<int>(
            value: 1,
            child: Text("Block User".tr),
          ),
          PopupMenuItem<int>(
            value: 2,
            child: Text("Copy Info".tr),
          ),
        ];
      },
    );
  }

  Widget _buildFakeNameFollow(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                userDetail?.name ?? "",
              ).h4(),
              Text(
                userDetail == null
                    ? ""
                    : '${"Follows".tr}: ${userDetail!.totalFollowUsers}',
              )
            ]),
      ),
    );
  }

  Widget _buildNameFollow(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              NullHero(
                tag: userDetail?.name ?? "${widget.heroTag}",
                child: Text(
                  userDetail?.name ?? "",
                ).h4(),
              ),
              InkWell(
                onTap: () {
                  Get.to(() =>
                      FollowList(id: widget.id.toString(), setAppBar: true));
                },
                child: Text(
                  userDetail == null
                      ? ""
                      : '${"Follows".tr}: ${userDetail!.totalFollowUsers}',
                ),
              )
            ]),
      ),
    );
  }

  Widget _buildComment(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 60,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
        child: SelectionArea(
          child: SingleChildScrollView(
            child: Text(
              userDetail == null ? "" : userDetail!.comment,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    Widget w = _buildAvatarFollow(context);
    return Stack(
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(top: 25),
          alignment: Alignment.bottomCenter,
          child: SizedBox(
            height: 55.0,
            child: Container(),
          ),
        ),
        Align(
          child: w,
          alignment: Alignment.bottomCenter,
        )
      ],
    );
  }

  Widget _buildAvatarFollow(BuildContext context) {
    return SizedBox(
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0.0),
            child: NullHero(
              tag: userDetail!.avatar + widget.heroTag.toString(),
              child: PainterAvatar(
                url: userDetail!.avatar,
                size: 80,
                onTap: () {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title:
                              Text("Save".tr).withAlign(Alignment.centerLeft),
                          content: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: CachedNetworkImage(
                              imageUrl: userDetail!.avatar,
                              fit: BoxFit.cover,
                              cacheManager: imagesCacheManager,
                            ),
                          ),
                          actions: [
                            OutlineButton(
                                onPressed: () async {
                                  Navigator.of(context).pop();
                                },
                                child: Text("Cancel".tr)),
                            PrimaryButton(
                                onPressed: () async {
                                  Navigator.of(context).pop();
                                  await _saveUserC(context);
                                },
                                child: Text("Ok".tr)),
                          ],
                        );
                      });
                },
                id: userDetail!.id,
              ),
            ),
          ),
          Container(
            child: userDetail == null
                ? Container(
                    padding: const EdgeInsets.only(right: 16.0, bottom: 4.0),
                    child: CircularProgressIndicator(),
                  )
                : Padding(
                    padding: const EdgeInsets.only(right: 16.0, bottom: 4.0),
                    child: UserFollowButton(
                      liked: userDetail!.isFollowed,
                      id: userDetail!.id.toString(),
                    ),
                  ),
          )
        ],
      ),
    );
  }

  _saveUserBg(BuildContext context, String url) async {
    try {
      saveUrl(url);
    } catch (e) {
      log.e(e);
    }
  }

  Future _saveUserC(BuildContext context) async {
    var url = userDetail!.avatar;
    String meme = url.split(".").last;
    if (meme.isEmpty) meme = "jpg";
    var replaceAll = userDetail!.name
        .replaceAll("/", "")
        .replaceAll("\\", "")
        .replaceAll(":", "")
        .replaceAll("*", "")
        .replaceAll("?", "")
        .replaceAll(">", "")
        .replaceAll("|", "")
        .replaceAll("<", "");
    String fileName = "${replaceAll}_${userDetail!.id}.${meme}";
    try {
      saveUrl(url, filenm: fileName);
    } catch (e) {
      log.e(e);
    }
  }

  firstLoad() {
    loadData().then((value) {
      if (value.success) {
        setState(() {
          userDetail = value.data;
          isMuted = localManager.blockedUsers.contains(userDetail!.name);
        });
      } else {
        setState(() {
          if (value.errorMessage != null &&
              value.errorMessage!.contains("timeout")) {
            Leader.showToast("Network Error. Please refresh to try again.".tr);
          }
        });
      }
    });
  }

  Future<Res<UserDetails>> loadData() async {
    return ConnectManager().apiClient.getUserDetails(widget.id);
  }
}
