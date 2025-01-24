import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get/get.dart';
import 'package:mobx/mobx.dart';
import 'package:skana_pix/pixiv_dart_api.dart';
import 'package:skana_pix/utils/translate.dart';

class BlockListPage extends StatefulWidget {
  @override
  _BlockListPageState createState() => _BlockListPageState();
}

class _BlockListPageState extends State<BlockListPage> {
  ObservableList<String> blockedTags = ObservableList();
  ObservableList<String> blockedNovelTags = ObservableList();

  ObservableList<String> blockedUsers = ObservableList();
  ObservableList<String> blockedCommentUsers = ObservableList();
  ObservableList<String> blockedNovelUsers = ObservableList();

  ObservableList<String> blockedIllusts = ObservableList();
  ObservableList<String> blockedNovels = ObservableList();

  ObservableList<String> blockedComments = ObservableList();

  @override
  void initState() {
    super.initState();
    loadDirects();
  }

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (_) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Block List'.tr),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: [
                    Text("Tags".tr),
                    IconButton(
                        onPressed: () {
                          _showBanTagAddDialog(false);
                        },
                        icon: Icon(Icons.add))
                  ],
                ),
                Container(
                  child: Wrap(
                    spacing: 2.0,
                    runSpacing: 2.0,
                    direction: Axis.horizontal,
                    children: blockedTags
                        .map((f) => ActionChip(
                              onPressed: () => deleteTag(context, f),
                              label: Text(f),
                            ))
                        .toList(),
                  ),
                ),
                Divider(),
                Row(
                  children: [
                    Text("Novel Tags".tr),
                    IconButton(
                        onPressed: () {
                          _showBanTagAddDialog(true);
                        },
                        icon: Icon(Icons.add))
                  ],
                ),
                Container(
                  child: Wrap(
                    spacing: 2.0,
                    runSpacing: 2.0,
                    direction: Axis.horizontal,
                    children: blockedNovelTags
                        .map((f) => ActionChip(
                              onPressed: () =>
                                  deleteTag(context, f, isNovel: true),
                              label: Text(f),
                            ))
                        .toList(),
                  ),
                ),
                Divider(),
                Row(
                  children: [
                    Text("Pianters".tr),
                    Opacity(
                      child:
                          IconButton(onPressed: () {}, icon: Icon(Icons.add)),
                      opacity: 0.0,
                    )
                  ],
                ),
                Container(
                  child: Wrap(
                    spacing: 2.0,
                    runSpacing: 2.0,
                    direction: Axis.horizontal,
                    children: blockedUsers
                        .map((f) => ActionChip(
                              onPressed: () => _deleteUserIdTag(
                                context,
                                f,
                                0,
                              ),
                              label: Text(f),
                            ))
                        .toList(),
                  ),
                ),
                Divider(),
                Row(
                  children: [
                    Text("Authors".tr),
                    Opacity(
                      child:
                          IconButton(onPressed: () {}, icon: Icon(Icons.add)),
                      opacity: 0.0,
                    )
                  ],
                ),
                Container(
                  child: Wrap(
                    spacing: 2.0,
                    runSpacing: 2.0,
                    direction: Axis.horizontal,
                    children: blockedNovelUsers
                        .map((f) => ActionChip(
                              onPressed: () => _deleteUserIdTag(
                                context,
                                f,
                                1,
                              ),
                              label: Text(f),
                            ))
                        .toList(),
                  ),
                ),
                Divider(),
                Row(
                  children: [
                    Text("Commentors".tr),
                    Opacity(
                      child:
                          IconButton(onPressed: () {}, icon: Icon(Icons.add)),
                      opacity: 0.0,
                    )
                  ],
                ),
                Container(
                  child: Wrap(
                    spacing: 2.0,
                    runSpacing: 2.0,
                    direction: Axis.horizontal,
                    children: blockedCommentUsers
                        .map((f) => ActionChip(
                              onPressed: () => _deleteUserIdTag(
                                context,
                                f,
                                2,
                              ),
                              label: Text(f),
                            ))
                        .toList(),
                  ),
                ),
                Divider(),
                Row(
                  children: [
                    Text("Illusts".tr),
                    Opacity(
                      child:
                          IconButton(onPressed: () {}, icon: Icon(Icons.add)),
                      opacity: 0.0,
                    )
                  ],
                ),
                Container(
                  child: Wrap(
                    spacing: 2.0,
                    runSpacing: 2.0,
                    direction: Axis.horizontal,
                    children: blockedIllusts
                        .map((f) => ActionChip(
                              onPressed: () => _delete(context, f, 0),
                              label: Text(f),
                            ))
                        .toList(),
                  ),
                ),
                Divider(),
                Row(
                  children: [
                    Text("Novels".tr),
                    Opacity(
                      child:
                          IconButton(onPressed: () {}, icon: Icon(Icons.add)),
                      opacity: 0.0,
                    )
                  ],
                ),
                Container(
                  child: Wrap(
                    spacing: 2.0,
                    runSpacing: 2.0,
                    direction: Axis.horizontal,
                    children: blockedNovels
                        .map((f) => ActionChip(
                              onPressed: () => _delete(context, f, 1),
                              label: Text(f),
                            ))
                        .toList(),
                  ),
                ),
                Divider(),
                Row(
                  children: [
                    Text("Comments".tr),
                    Opacity(
                      child:
                          IconButton(onPressed: () {}, icon: Icon(Icons.add)),
                      opacity: 0.0,
                    )
                  ],
                ),
                Container(
                  child: Wrap(
                    spacing: 2.0,
                    runSpacing: 2.0,
                    direction: Axis.horizontal,
                    children: blockedComments
                        .map((f) => ActionChip(
                              onPressed: () => _delete(context, f, 2),
                              label: Text(f.atMost13),
                            ))
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  _showBanTagAddDialog(bool isNovel) async {
    final controller = TextEditingController();
    final result = await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Add"),
            content: TextField(
              controller: controller,
              decoration: InputDecoration(
                  hintText: isNovel ? "Novel Tag".tr : "Tag".tr,
                  hintStyle: TextStyle(fontSize: 12)),
            ),
            actions: <Widget>[
              TextButton(
                child: Text("Cancel".tr),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context, controller.text);
                },
                child: Text("Ok".tr),
              ),
            ],
          );
        });
    if (result != null && result is String && result.isNotEmpty) {
      setState(() {
        if (isNovel) {
          settings.addBlockedNovelTags([result]);
          blockedNovelTags.add(result);
        } else {
          settings.addBlockedTags([result]);
          blockedTags.add(result);
        }
      });
    }
  }

  Future deleteTag(BuildContext context, String f,
      {bool isNovel = false}) async {
    final result = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Delete".tr),
          content: Text('Delete this tag?'.tr),
          actions: <Widget>[
            TextButton(
              child: Text("Cancel".tr),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, "OK");
              },
              child: Text("Ok".tr),
            ),
          ],
        );
      },
    );
    switch (result) {
      case "OK":
        {
          if (isNovel) {
            setState(() {
              settings.removeBlockedNovelTags([f]);
              blockedNovelTags.remove(f);
            });
          } else {
            setState(() {
              settings.removeBlockedTags([f]);
              blockedTags.remove(f);
            });
          }
        }
        break;
    }
  }

  Future _deleteUserIdTag(BuildContext context, String f, int type) async {
    final result = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Delete".tr),
          content: Text('Delete this user?'.tr),
          actions: <Widget>[
            TextButton(
              child: Text("Cancel".tr),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, "OK");
              },
              child: Text("Ok".tr),
            ),
          ],
        );
      },
    );
    switch (result) {
      case "OK":
        {
          switch (type) {
            case 0:
              {
                setState(() {
                  settings.removeBlockedUsers([f]);
                  blockedUsers.remove(f);
                });
              }
              break;
            case 1:
              {
                setState(() {
                  settings.removeBlockedNovelUsers([f]);
                  blockedNovelUsers.remove(f);
                });
              }
              break;
            case 2:
              {
                setState(() {
                  settings.removeBlockedCommentUsers([f]);
                  blockedCommentUsers.remove(f);
                });
              }
              break;
          }
        }
        break;
    }
  }

  Future _delete(BuildContext context, String f, int type) async {
    final result = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Delete".tr),
          content: Text("${'Delete'.tr}?"),
          actions: <Widget>[
            TextButton(
              child: Text("Cancel".tr),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, "OK");
              },
              child: Text("Ok".tr),
            ),
          ],
        );
      },
    );
    switch (result) {
      case "OK":
        {
          switch (type) {
            case 0:
              {
                setState(() {
                  settings.removeBlockedIllusts([f]);
                  blockedIllusts.remove(f);
                });
              }
              break;
            case 1:
              {
                setState(() {
                  settings.removeBlockedNovels([f]);
                  blockedNovels.remove(f);
                });
              }
              break;
            case 2:
              {
                setState(() {
                  settings.removeBlockedComments([f]);
                  blockedComments.remove(f);
                });
                break;
              }
          }
          break;
        }
    }
  }
}
