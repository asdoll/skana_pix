import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:flutter/material.dart' show InkWell;
import 'package:skana_pix/componentwidgets/backarea.dart';
import 'package:skana_pix/utils/widgetplugin.dart';
import 'package:skana_pix/view/imageview/imagelistview.dart';
import 'package:skana_pix/view/novelview/novelpage.dart';
import 'package:skana_pix/componentwidgets/userpage.dart';
import 'package:skana_pix/view/userview/usersearch.dart';
import 'package:skana_pix/controller/search_controller.dart';
import 'package:skana_pix/model/worktypes.dart';
import 'package:get/get.dart';

import '../../utils/leaders.dart';
import '../novelview/novelresult.dart';
import '../imageview/imagesearchresult.dart';
import '../souppage.dart';

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
                          ).paddingVertical(2);
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
                          ).paddingVertical(2);
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
                          ).paddingVertical(2);
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
                          ).paddingVertical(2);
                        }
                        return Basic();
                      }, childCount: 4),
                    ).sliverPadding(EdgeInsets.only(left: 8)),
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
                                return IllustResultPage(
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
                        ).paddingVertical(2);
                      }, childCount: _suggestionStore.autoWords.length),
                    ).sliverPadding(EdgeInsets.only(left: 8)),
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
      leading: [
        const NormalBackButton(),
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
        trailing: IconButton.ghost(
          icon: Icon(Icons.close),
          onPressed: () {
            _filter.clear();
          },
        ),
        style: Theme.of(context)
            .typography
            .xSmall
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
          Get.to(() {
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
            return IllustResultPage(
              word: word,
            );
          });
        },
        placeholder: Text("Enter keywords or links".tr).xSmall());
  }
}
