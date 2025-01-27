import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:flutter/material.dart' show InkWell;
import 'package:skana_pix/componentwidgets/imagelist.dart';
import 'package:skana_pix/componentwidgets/novelpage.dart';
import 'package:skana_pix/componentwidgets/userpage.dart';
import 'package:skana_pix/componentwidgets/usersearch.dart';
import 'package:skana_pix/controller/search_controller.dart';
import 'package:skana_pix/model/worktypes.dart';
import 'package:get/get.dart';

import '../utils/leaders.dart';
import '../componentwidgets/novelresult.dart';
import '../componentwidgets/searchresult.dart';
import 'souppage.dart';

class SearchSuggestionPage extends StatefulWidget {
  final String? preword;
  final ArtworkType type;
  const SearchSuggestionPage(this.type, {super.key, this.preword});

  @override
  State<SearchSuggestionPage> createState() => _SearchSuggestionPageState();
}

class _SearchSuggestionPageState extends State<SearchSuggestionPage> {
  late TextEditingController _filter;
  late SuggestionStore _suggestionStore;
  FocusNode focusNode = FocusNode();
  final tagGroup = [];
  bool idV = false;
  late ArtworkType type;

  @override
  void initState() {
    idV = widget.preword != null && int.tryParse(widget.preword!) != null;
    _suggestionStore = Get.put(SuggestionStore());
    var query = widget.preword ?? '';
    _filter = TextEditingController(text: query);
    var tags = query
        .split(" ")
        .map((e) => e.trim())
        .takeWhile((value) => value.isNotEmpty);
    if (tags.length > 1) tagGroup.addAll(tags);
    type = widget.type;
    super.initState();
  }

  @override
  void dispose() {
    Get.delete<SuggestionStore>();
    _filter.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Scaffold(
        headers: [
          _buildAppBar(context),
          const Divider(),
        ],
        child: Column(
          children: [
            Expanded(
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Wrap(
                        spacing: 10,
                        children: [
                          for (String i in tagGroup)
                            Chip(
                                child: Text(i),
                                onPressed: () {
                                  final start = _filter.text.indexOf(i);
                                  if (start != -1) {
                                    _filter.selection =
                                        TextSelection.fromPosition(TextPosition(
                                            offset: start + i.length));
                                  }
                                })
                        ],
                      ),
                    ),
                  ),
                  SliverVisibility(
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        if (index == 0) {
                          return InkWell(
                            onTap: () {
                              Get.to(() => IllustPageLite(_filter.text),
                                  preventDuplicates: false);
                            },
                            child: Basic(
                              title: Text(_filter.text),
                              subtitle: Text("Artwork ID".tr),
                            ),
                          );
                        }
                        if (index == 1) {
                          return InkWell(
                            onTap: () {
                              Get.to(() => NovelPageLite(_filter.text),
                                  preventDuplicates: false);
                            },
                            child: Basic(
                              title: Text(_filter.text),
                              subtitle: Text("Novel ID".tr),
                            ),
                          );
                        }
                        if (index == 2) {
                          return InkWell(
                            onTap: () {
                              Get.to(() => UserPage(
                                  id: int.tryParse(_filter.text)!,
                                  type: ArtworkType.ALL));
                            },
                            child: Basic(
                              title: Text(_filter.text),
                              subtitle: Text("Artist ID".tr),
                            ),
                          );
                        }
                        if (index == 3 && _filter.text.length < 5) {
                          return InkWell(
                            onTap: () {
                              Get.to(() => SoupPage(
                                  url:
                                      "https://www.pixivision.net/zh/a/${_filter.text.trim()}",
                                  spotlight: null));
                            },
                            child: Basic(
                              title: Text(_filter.text),
                              subtitle: Text("Pixivision".tr),
                            ),
                          );
                        }
                        return Basic();
                      }, childCount: 4),
                    ),
                    visible: idV,
                  ),
                  if (_suggestionStore.autoWords.isNotEmpty)
                    SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final tags = _suggestionStore.autoWords;
                        return InkWell(
                          onTap: () {
                            if (tagGroup.length > 1) {
                              tagGroup.last = tags[index].name;
                              var text = tagGroup.join(" ");
                              _filter.text = text;
                              _filter.selection = TextSelection.fromPosition(
                                  TextPosition(offset: text.length));
                              setState(() {});
                            } else {
                              FocusScope.of(context).unfocus();
                              Get.to(() {
                                if (type == ArtworkType.NOVEL) {
                                  return NovelResultPage(
                                    word: tags[index].name,
                                    translatedName:
                                        tags[index].translatedName ?? "",
                                  );
                                }
                                if (type == ArtworkType.USER) {
                                  return UserResultPage(
                                    word: tags[index].name,
                                    translatedName:
                                        tags[index].translatedName ?? "",
                                  );
                                }
                                return ResultPage(
                                  word: tags[index].name,
                                  translatedName:
                                      tags[index].translatedName ?? "",
                                );
                              }, preventDuplicates: false);
                            }
                          },
                          child: Basic(
                            title: Text(tags[index].name),
                            subtitle: Text(tags[index].translatedName ?? ""),
                          ),
                        );
                      }, childCount: _suggestionStore.autoWords.length),
                    ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  AppBar _buildAppBar(context) {
    return AppBar(
      title: _textField(context, TextInputType.text, focusNode),
      trailing: <Widget>[
        IconButton.outline(
          icon: Icon(Icons.close),
          onPressed: () {
            _filter.clear();
          },
        ),
        Select<String>(
          itemBuilder: (context, value) {
            return Text(value.tr);
          },
          children: [
            SelectItemButton(value: "Artwork", child: Text("Artwork".tr)),
            SelectItemButton(value: "Novel", child: Text("Novel".tr)),
            SelectItemButton(value: "User", child: Text("User".tr)),
          ],
          onChanged: (value) {
            setState(() {
              if (value == null) return;
              switch (value) {
                case "Artwork":
                  type = ArtworkType.ILLUST;
                  break;
                case "Novel":
                  type = ArtworkType.NOVEL;
                  break;
                case "User":
                  type = ArtworkType.USER;
                  break;
              }
            });
          },
        ),
      ],
    );
  }

  TextField _textField(
      BuildContext context, TextInputType inputType, FocusNode node) {
    return TextField(
        controller: _filter,
        focusNode: node,
        keyboardType: inputType,
        autofocus: true,
        style: Theme.of(context)
            .typography
            .h3
            .copyWith(color: Theme.of(context).colorScheme.input),
        onTap: () {
          FocusScope.of(context).requestFocus(node);
        },
        onChanged: (query) {
          tagGroup.clear();
          var tags = query
              .split(" ")
              .map((e) => e.trim())
              .takeWhile((value) => value.isNotEmpty);
          if (tags.length > 1) tagGroup.addAll(tags);
          setState(() {});
          bool isNum = int.tryParse(query) != null;
          setState(() {
            idV = isNum;
          });
          if (query.startsWith('https://')) {
            Leader.pushWithUri(context, Uri.parse(query));
            _filter.clear();
            return;
          }
          var word = query.trim();
          if (word.isEmpty) return;
          if (isNum && word.length > 5) return; //超过五个数字应该就不需要给建议了吧
          word = tags.last;
          if (word.isEmpty) return;
          _suggestionStore.fetch(word);
        },
        onSubmitted: (s) {
          var word = s.trim();
          if (word.isEmpty) return;
          Navigator.of(context, rootNavigator: true)
              .push(MaterialPageRoute(builder: (context) {
            if (type == ArtworkType.NOVEL) {
              return NovelResultPage(
                word: word,
              );
            }
            if (type == ArtworkType.ALL) {
              return UserResultPage(
                word: word,
              );
            }
            return ResultPage(
              word: word,
            );
          }));
        },
        placeholder: Text("Enter keywords or links".tr));
  }
}
