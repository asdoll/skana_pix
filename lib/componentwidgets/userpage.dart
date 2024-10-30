import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:icon_decoration/icon_decoration.dart';
import 'package:mobx/mobx.dart';
import 'package:path/path.dart';
import 'package:share_plus/share_plus.dart';
import 'package:skana_pix/componentwidgets/userdetail.dart';
import 'package:skana_pix/componentwidgets/userworks.dart';
import 'package:skana_pix/controller/caches.dart';
import 'package:skana_pix/model/worktypes.dart';
import 'package:skana_pix/pixiv_dart_api.dart';
import 'package:skana_pix/utils/translate.dart';
import 'package:skana_pix/utils/widgetplugin.dart';

import 'avatar.dart';
import 'backarea.dart';
import 'followbutton.dart';
import 'followlist.dart';
import 'nullhero.dart';
import 'userbookmarks.dart';

class UserPage extends StatefulWidget {
  final ArtworkType type;
  final String? heroTag;
  final int id;
  final bool isMe;
  const UserPage(
      {Key? key,
      required this.id,
      this.heroTag,
      this.type = ArtworkType.ALL,
      this.isMe = false})
      : super(key: key);

  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> with TickerProviderStateMixin {
  late TabController _tabController;
  late ScrollController _scrollController;
  bool backToTopVisible = false;
  UserDetails? userDetail;
  bool isMuted = false;
  bool isError = false;
  ArtworkType get type =>
      widget.type == ArtworkType.ALL ? ArtworkType.ILLUST : widget.type;

  String restrict = 'public';

  @override
  void initState() {
    _tabController = TabController(length: 3, vsync: this);
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
    isMuted = settings.blockedUsers.contains(widget.id.toString());
    firstLoad();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  int _tabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Observer(
        warnWhenNoObservables: false,
        builder: (_) {
          if (isMuted) {
            return Scaffold(
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0.0,
              ),
              extendBodyBehindAppBar: true,
              extendBody: true,
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text('X_X'),
                    Text('${widget.id}'),
                    FilledButton.tonal(
                        onPressed: () {
                          settings.removeBlockedUsers([widget.id.toString()]);
                          setState(() {
                            isMuted = false;
                          });
                        },
                        child: Text("Unblock".i18n)),
                  ],
                ),
              ),
            );
          }

          if (isError && userDetail == null) {
            return Scaffold(
              appBar: AppBar(),
              body: Container(
                  child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "Network Error".i18n,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: MaterialButton(
                        color: Theme.of(context).colorScheme.primary,
                        onPressed: () {
                          firstLoad();
                        },
                        child: Text("Retry".i18n),
                      ),
                    )
                  ],
                ),
              )),
            );
          }
          if (userDetail == null) {
            return Scaffold(
              appBar: AppBar(),
              body: Container(
                  child: Center(
                child: CircularProgressIndicator(
                  color: Theme.of(context).colorScheme.primary,
                ),
              )),
            );
          }
          return _buildBody(context);
        });
  }

  Widget _buildBody(BuildContext context) {
    return Container(
      child: Scaffold(
        body: NestedScrollView(
          controller: _scrollController,
          body: TabBarView(controller: _tabController, children: [
            WorksPage(
                id: userDetail!.id,
                type: type,
                portal: '/works-${userDetail!.id}'),
            BookmarksPage(
                id: userDetail!.id,
                type: type,
                portal: '/bookmarks-${userDetail!.id}'),
            UserDetailPage(userDetail!),
          ]).paddingTop(102 + MediaQuery.of(context).padding.top),
          headerSliverBuilder:
              (BuildContext context, bool? innerBoxIsScrolled) {
            return _HeaderSlivers(innerBoxIsScrolled, context);
          },
        ),
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
              return IconButton(
                  icon: const DecoratedIcon(
                    icon: Icon(Icons.share),
                    decoration: IconDecoration(border: IconBorder(width: 1.5)),
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
            background: Container(
              color: Theme.of(context).cardColor,
              child: Stack(
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
                        Container(
                          color: Theme.of(context).cardColor,
                          child: Column(
                            children: <Widget>[
                              _buildNameFollow(context),
                              _buildComment(context),
                              Tab(
                                text: " ",
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
          bottom: ColoredTabBar(
            Theme.of(context).cardColor,
            TabBar(
              controller: _tabController,
              onTap: (index) {
                setState(() {
                  _tabIndex = index;
                });
              },
              tabs: [
                GestureDetector(
                  onDoubleTap: () {
                    if (_tabIndex == 0) _scrollController.position.jumpTo(0);
                  },
                  child: Tab(
                    text: "Artworks".i18n,
                  ),
                ),
                GestureDetector(
                  onDoubleTap: () {
                    if (_tabIndex == 1) _scrollController.position.jumpTo(0);
                  },
                  child: Tab(
                    text: "Bookmarks".i18n,
                  ),
                ),
                GestureDetector(
                  onDoubleTap: () {
                    if (_tabIndex == 2) _scrollController.position.jumpTo(0);
                  },
                  child: Tab(
                    text: "Details".i18n,
                  ),
                ),
              ],
            ),
          ),
        ),
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
            color: Theme.of(context).cardColor,
          ),
          Container(
            color: Theme.of(context).cardColor,
            child: Column(
              children: <Widget>[
                _buildFakeNameFollow(context),
                Container(
                  height: 60,
                ),
                const Tab(
                  text: " ",
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground(BuildContext context) {
    return Container(
        width: MediaQuery.of(context).size.width,
        height: userDetail?.backgroundImage != null
            ? MediaQuery.of(context).size.width / 2
            : MediaQuery.of(context).padding.top + 160,
        child: userDetail != null
            ? userDetail!.backgroundImage != null
                ? InkWell(
                    onLongPress: () {
                      showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Text("Save".i18n),
                              content: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: CachedNetworkImage(
                                  imageUrl: userDetail!.backgroundImage!,
                                  fit: BoxFit.cover,
                                  cacheManager: imagesCacheManager,
                                ),
                              ),
                              actions: [
                                TextButton(
                                    onPressed: () async {
                                      Navigator.of(context).pop();
                                    },
                                    child: Text("Cancel".i18n)),
                                TextButton(
                                    onPressed: () async {
                                      Navigator.of(context).pop();
                                      await _saveUserBg(context,
                                          userDetail!.backgroundImage!);
                                    },
                                    child: Text("Ok".i18n)),
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
              BotToast.showText(text: "You can't follow yourself".i18n);
              return;
            }
            follow("private");
            
            break;
          case 1:
            {
              final result = await showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text('${"Block User".i18n}?'),
                      actions: <Widget>[
                        TextButton(
                          child: Text("Ok".i18n),
                          onPressed: () {
                            Navigator.of(context).pop("OK");
                          },
                        ),
                        TextButton(
                          child: Text("Cancel".i18n),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        )
                      ],
                    );
                  });
              if (result == "OK") {
                settings.addBlockedUsers([widget.id.toString()]);
                setState(() {
                  isMuted = true;
                });
                Navigator.of(context).pop();
              }
            }
            break;
          case 2:
            {
              Clipboard.setData(ClipboardData(
                  text: 'painter:${userDetail?.name ?? ''}\npid:${widget.id}'));
              BotToast.showText(text: "Copied to clipboard".i18n);
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
              child: Text("Follow privately".i18n),
            ),
          PopupMenuItem<int>(
            value: 1,
            child: Text("Block User".i18n),
          ),
          PopupMenuItem<int>(
            value: 2,
            child: Text("Copy Info".i18n),
          ),
        ];
      },
    );
  }

  Widget _buildFakeNameFollow(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                userDetail?.name ?? "",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Text(
                userDetail == null
                    ? ""
                    : '${userDetail!.totalFollowUsers} ${"Follow".i18n}',
                style: Theme.of(context).textTheme.bodySmall,
              )
            ]),
      ),
    );
  }

  Widget _buildNameFollow(BuildContext context) {
    return Container(
      color: Theme.of(context).cardColor,
      width: MediaQuery.of(context).size.width,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              NullHero(
                tag: userDetail?.name ?? "" + widget.heroTag.toString(),
                child: Text(
                  userDetail?.name ?? "",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              InkWell(
                onTap: () {
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (BuildContext context) {
                    return Scaffold(
                      appBar: AppBar(
                        title: Text("Followed".i18n),
                      ),
                      body: FollowList(id: widget.id),
                    );
                  }));
                },
                child: Text(
                  userDetail == null
                      ? ""
                      : '${userDetail!.totalFollowUsers} ${"Follow".i18n}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              )
            ]),
      ),
    );
  }

  Widget _buildComment(BuildContext context) {
    return Container(
      color: Theme.of(context).cardColor,
      width: MediaQuery.of(context).size.width,
      height: 60,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
        child: SelectionArea(
          child: SingleChildScrollView(
            child: Text(
              userDetail == null ? "" : userDetail!.comment,
              style: Theme.of(context).textTheme.bodySmall,
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
            child: Container(
              color: Theme.of(context).cardColor,
            ),
          ),
        ),
        Align(
          child: w,
          alignment: Alignment.bottomCenter,
        )
      ],
    );
  }

  Container _buildAvatarFollow(BuildContext context) {
    return Container(
      child: Observer(
        warnWhenNoObservables: false,
        builder: (_) => Row(
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
                  size: Size(80, 80),
                  onTap: () {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text("Save".i18n),
                            content: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: CachedNetworkImage(
                                imageUrl: userDetail!.avatar,
                                fit: BoxFit.cover,
                                cacheManager: imagesCacheManager,
                              ),
                            ),
                            actions: [
                              TextButton(
                                  onPressed: () async {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text("Cancel".i18n)),
                              TextButton(
                                  onPressed: () async {
                                    Navigator.of(context).pop();
                                    await _saveUserC(context);
                                  },
                                  child: Text("Ok".i18n)),
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
                      child: CircularProgressIndicator(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.only(right: 16.0, bottom: 4.0),
                      child: UserFollowButton(
                        followed: userDetail!.isFollowed,
                        onPressed: () async {
                          if (widget.isMe) {
                            BotToast.showText(
                                text: "You can't follow yourself".i18n);
                            return;
                          }
                          follow("public");
                        },
                      ),
                    ),
            )
          ],
        ),
      ),
    );
  }

  _saveUserBg(BuildContext context, String url) async {
    try {
      final result = await imagesCacheManager.downloadFile(url, authHeaders: {
        'referer': 'https://app-api.pixiv.net/',
      });
      final path = result.file.path;
      final box = context.findRenderObject() as RenderBox?;
      Share.shareXFiles([XFile(path)],
          sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size);
    } catch (e) {
      print(e);
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
      var file = await imagesCacheManager.getFileFromCache(url);
      if (file != null) {
        String targetPath = join(BasePath.cachePath, "share_cache", fileName);
        File targetFile = File(targetPath);
        if (!targetFile.existsSync()) {
          targetFile.createSync(recursive: true);
        }
        file.file.copySync(targetPath);
        final box = context.findRenderObject() as RenderBox?;
        Share.shareXFiles([XFile(targetPath)],
            sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size);
      } else {
        BotToast.showText(text: "can not find image cache");
      }
    } catch (e) {
      print(e);
    }
  }

  bool isFollowing = false;

  void follow(String type) async {
    if (isFollowing) return;
    setState(() {
      isFollowing = true;
    });
    var method = userDetail!.isFollowed ? "delete" : "add";
    var res = await followUser(userDetail!.id.toString(), method, type);
    if (res.error) {
      if (mounted) {
        BotToast.showText(text: "Network Error".i18n);
      }
    } else {
      if (method == "add" && type == "private") {
        BotToast.showText(text: "Followed privately".i18n);
      } else {
        BotToast.showText(
            text: userDetail!.isFollowed
                ? "Unfollowed".i18n
                : "Followed".i18n);
      }
      userDetail!.isFollowed = !userDetail!.isFollowed;
    }
    setState(() {
      isFollowing = false;
    });
    // UserInfoPage.followCallbacks[widget.illust.author.id.toString()]
    //     ?.call(widget.illust.author.isFollowed);
    // UserPreviewWidget.followCallbacks[widget.illust.author.id.toString()]
    //      ?.call(widget.illust.author.isFollowed);
  }

  firstLoad() {
    loadData().then((value) {
      if (value.success) {
        setState(() {
          userDetail = value.data;
        });
      } else {
        setState(() {
          if (value.errorMessage != null &&
              value.errorMessage!.contains("timeout")) {
            BotToast.showText(
                text: "Network Error. Please refresh to try again.".i18n);
          }
        });
      }
    });
  }

  Future<Res<UserDetails>> loadData() async {
    return ConnectManager().apiClient.getUserDetails(widget.id);
  }
}

class UserStore {
  final int id;
  UserStore(this.id);
  bool isLoading = false;
  UserDetails? userDetail;
  ObservableList<Illust> illusts = ObservableList();
  ObservableList<Illust> mangas = ObservableList();
  ObservableList<Illust> bookmarks = ObservableList();
  ObservableList<Novel> novels = ObservableList();
  ObservableList<Novel> novelbookmarks = ObservableList();
  bool isError = false;
  String? urlIllust;
  String? urlIllustBM;
  String? urlNovel;
  String? urlNovelBM;
  void fetch() async {
    if (isLoading) return;
    isLoading = true;
    if (urlIllust != "end") {
      ConnectManager()
          .apiClient
          .getUserIllusts(id.toString(), urlIllust)
          .then((value) {
        if (value.success) {
          for (Illust illust in value.data) {
            if (illust.type == "illust") {
              illusts.add(illust);
            } else {
              mangas.add(illust);
            }
          }
          if (value.subData != null) {
            urlIllust = value.subData;
          } else {
            urlIllust = "end";
          }
        } else {
          isError = true;
        }
      });
    }
    if (urlIllustBM != "end") {
      ConnectManager()
          .apiClient
          .getUserBookmarks(id.toString(), urlIllustBM)
          .then((value) {
        if (value.success) {
          bookmarks.addAll(value.data);
          if (value.subData != null) {
            urlIllustBM = value.subData;
          } else {
            urlIllustBM = "end";
          }
        } else {
          isError = true;
        }
      });
    }
    if (urlNovel != "end") {
      ConnectManager()
          .apiClient
          .getUserNovels(id.toString(), urlNovel)
          .then((value) {
        if (value.success) {
          novels.addAll(value.data);
          if (value.subData != null) {
            urlNovel = value.subData;
          } else {
            urlNovel = "end";
          }
        } else {
          isError = true;
        }
      });
    }
    if (urlNovelBM != "end") {
      ConnectManager()
          .apiClient
          .getBookmarkedNovels(id.toString(), urlNovelBM)
          .then((value) {
        if (value.success) {
          novelbookmarks.addAll(value.data);
          if (value.subData != null) {
            urlNovelBM = value.subData;
          } else {
            urlNovelBM = "end";
          }
        } else {
          isError = true;
        }
      });
    }
    isLoading = false;
  }

  void reset() {
    isLoading = false;
    userDetail = null;
    illusts.clear();
    bookmarks.clear();
    novels.clear();
    novelbookmarks.clear();
    isError = false;
    urlIllust = null;
    urlIllustBM = null;
    urlNovel = null;
    urlNovelBM = null;
    fetch();
  }
}

class StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar child;

  StickyTabBarDelegate({required this.child});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      child: this.child,
      color: Theme.of(context).cardColor,
    );
  }

  @override
  double get maxExtent => this.child.preferredSize.height;

  @override
  double get minExtent => this.child.preferredSize.height;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}

class ColoredTabBar extends Container implements PreferredSizeWidget {
  ColoredTabBar(this.color, this.tabBar);

  final Color color;
  final TabBar tabBar;

  @override
  Size get preferredSize => tabBar.preferredSize;

  @override
  Widget build(BuildContext context) => Container(
        color: color,
        child: tabBar,
      );
}
