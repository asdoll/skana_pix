import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:icon_decoration/icon_decoration.dart';
import 'package:moon_design/moon_design.dart';
import 'package:share_plus/share_plus.dart';
import 'package:skana_pix/componentwidgets/headerfooter.dart';
import 'package:skana_pix/componentwidgets/userdetail.dart';
import 'package:skana_pix/controller/connector.dart';
import 'package:skana_pix/controller/logging.dart';
import 'package:skana_pix/controller/res.dart';
import 'package:skana_pix/controller/settings.dart';
import 'package:skana_pix/model/user.dart';
import 'package:skana_pix/utils/io_extension.dart';
import 'package:skana_pix/view/userview/userworks.dart';
import 'package:skana_pix/controller/caches.dart';
import 'package:skana_pix/controller/like_controller.dart';
import 'package:skana_pix/model/worktypes.dart';
import 'package:get/get.dart';
import 'package:skana_pix/utils/leaders.dart';
import 'package:skana_pix/utils/widgetplugin.dart';

import '../../componentwidgets/avatar.dart';
import '../../componentwidgets/backarea.dart';
import '../../componentwidgets/followbutton.dart';
import 'followlist.dart';
import '../../componentwidgets/nullhero.dart';
import '../bookmarkspage.dart';

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
  bool backToTopVisible = false;
  UserDetails? userDetail;
  bool isMuted = false;
  bool isError = false;
  ArtworkType get type =>
      widget.type == ArtworkType.ALL ? ArtworkType.ILLUST : widget.type;
  late TabController tabController;

  String restrict = 'public';

  @override
  void initState() {
    tabController = TabController(length: 3, vsync: this);
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
    _scrollController.dispose();
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isMuted) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text('X_X'),
              Text('${widget.id}'),
              filledButton(
                  onPressed: () {
                    settings.removeBlockedUsers([widget.id.toString()]);
                    setState(() {
                      isMuted = false;
                    });
                  },
                  label: "Unblock".tr),
            ],
          ),
        ),
      );
    }

    if (isError && userDetail == null) {
      return Scaffold(
        body: Center(
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
                child: filledButton(
                  onPressed: () {
                    firstLoad();
                  },
                  label: "Retry".tr,
                ),
              )
            ],
          ),
        ),
      );
    }
    if (userDetail == null) {
      return Scaffold(
        body: Center(
            child: DefaultHeaderFooter.progressIndicator(context)
            ),
      );
    }
    return _buildBody(context);
  }

  Widget _buildBody(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        controller: _scrollController,
        body: TabBarView(
          controller: tabController,
          children: [
            WorksPage(
              id: userDetail!.id,
              type: type,
              noScroll: true,
            ),
            BookmarksPage(
              id: userDetail!.id,
              type: type,
              noScroll: true,
            ),
            UserDetailPage(userDetail!)
          ],
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
                return MoonButton.icon(
                  buttonSize: MoonButtonSize.sm,
                    icon: const DecoratedIcon(
                      icon: Icon(Icons.share,color: Colors.white),
                      decoration:
                          IconDecoration(border: IconBorder(width: 1.5)),
                    ),
                    onTap: () {
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
                  _buildBackground(context).paddingBottom(12),
                  _buildFakeBg(context).paddingBottom(12),
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
                            ).header(),
                          ],
                        ).paddingBottom(12),
                      ],
                    ),
                  )
                ],
              ),
            ),
            bottom: PreferredSize(
                preferredSize: Size.fromHeight(48),
                child: MoonTabBar(
                  tabController: tabController,
                  tabs: [
                    MoonTab(
                      label: Text(
                        "Artworks".tr,
                          ),
                        ),
                        MoonTab(
                          label: Text(
                            "Bookmarks".tr,
                          ),
                        ),
                        MoonTab(
                          label: Text(
                            "Details".tr,
                          ),
                        )
                      ],
                    ))),
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
              ).header()
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
                      showMoonModal<void>(
                          context: context,
                          builder: (context) {
                            return Dialog(
                                child: ListView(
                                  shrinkWrap: true,
                                  children: [
                                  MoonAlert(
                                      borderColor: Get.context?.moonTheme
                                          ?.buttonTheme.colors.borderColor
                                          .withValues(alpha: 0.5),
                                      showBorder: true,
                                      label: Text("Save".tr).header(),
                                      verticalGap: 16,
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            child: CachedNetworkImage(
                                              imageUrl:
                                                  userDetail!.backgroundImage!,
                                              fit: BoxFit.cover,
                                              cacheManager: imagesCacheManager,
                                            ),
                                          ).paddingBottom(16),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              outlinedButton(
                                                label: "Cancel".tr,
                                                onPressed: () {
                                                  Get.back();
                                                },
                                              ).paddingRight(8),
                                              filledButton(
                                                label: "Ok".tr,
                                                onPressed: () async {
                                                  Get.back();
                                                  await _saveUserBg(
                                                      context,
                                                      userDetail!
                                                          .backgroundImage!);
                                                },
                                              ).paddingRight(8),
                                            ],
                                          )
                                        ],
                                      )),
                                ]));
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
      icon: DecoratedIcon(
        icon: Icon(Icons.more_vert,color: Colors.white,),
        decoration: const IconDecoration(border: IconBorder(width: 1.5)),
      ),
      onSelected: (index) async {
        switch (index) {
          case 0:
            if (widget.isMe) {
              Leader.showToast("You can't follow yourself".tr);
              return;
            }
            ConnectManager()
                .apiClient
                .follow(userDetail!.id.toString(), "add", "private");
            break;
          case 1:
            {
              final result = await alertDialog(
                  context, "Block User".tr, "${"Block User".tr}?", [
                outlinedButton(
                  label: "Cancel".tr,
                  onPressed: () {
                    Get.back();
                  },
                ),
                filledButton(
                  label: "Ok".tr,
                  onPressed: () {
                    Get.back(result: "OK");
                  },
                ),
              ]);
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
              ).header(),
              Text(
                userDetail == null
                    ? ""
                    : '${"Follows".tr}: ${userDetail!.totalFollowUsers}',
              ).subHeader(),
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
                ).header(),
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
                ).subHeader(),
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
            ).small(),
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
                  showMoonModal(
                      context: context,
                      builder: (context) => Dialog(
                              child: ListView(
                                  shrinkWrap: true,
                                  children: [
                                MoonAlert(
                                    borderColor: Get.context?.moonTheme
                                        ?.buttonTheme.colors.borderColor
                                        .withValues(alpha: 0.5),
                                    showBorder: true,
                                    label: Text("Save".tr).header(),
                                    verticalGap: 16,
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          child: CachedNetworkImage(
                                            imageUrl: userDetail!.avatar,
                                            fit: BoxFit.cover,
                                            cacheManager: imagesCacheManager,
                                          ),
                                        ).paddingBottom(16),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            outlinedButton(
                                              label: "Cancel".tr,
                                              onPressed: () {
                                                Get.back();
                                              },
                                            ).paddingRight(8),
                                            filledButton(
                                              label: "Ok".tr,
                                              onPressed: () async {
                                                Get.back();
                                                await _saveUserC(context);
                                              },
                                            ).paddingRight(8),
                                          ],
                                        )
                                      ],
                                    )),
                              ])));
                },
                id: userDetail!.id,
              ),
            ),
          ),
          Container(
            child: userDetail == null
                ? Container(
                    padding: const EdgeInsets.only(right: 16.0, bottom: 4.0),
                    child: DefaultHeaderFooter.progressIndicator(context),
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
