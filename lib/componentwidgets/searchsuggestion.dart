import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobx/mobx.dart';
import 'package:skana_pix/componentwidgets/imagetab.dart';
import 'package:skana_pix/componentwidgets/userpage.dart';
import 'package:skana_pix/componentwidgets/usersearch.dart';
import 'package:skana_pix/model/worktypes.dart';
import 'package:skana_pix/pixiv_dart_api.dart';
import 'package:skana_pix/utils/translate.dart';
import 'package:skana_pix/utils/widgetplugin.dart';

import '../utils/leaders.dart';
import 'novelresult.dart';
import 'searchresult.dart';
import 'souppage.dart';

class SearchSuggestionPage extends StatefulWidget {
  final String? preword;
  final ArtworkType type;
  SearchSuggestionPage(this.type, {this.preword});

  @override
  _SearchSuggestionPageState createState() => _SearchSuggestionPageState();
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
    _suggestionStore = SuggestionStore();
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
    _filter.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (context) {
      return Scaffold(
        appBar: _buildAppBar(context),
        body: Container(
            child: Column(
          children: [
            Container(
              height: 1,
              color: Theme.of(context).dividerColor,
            ),
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
                            ActionChip(
                                label: Text(i),
                                onPressed: () {
                                  final start = _filter.text.indexOf(i);
                                  if (start != -1)
                                    _filter.selection =
                                        TextSelection.fromPosition(TextPosition(
                                            offset: start + i.length));
                                })
                        ],
                      ),
                    ),
                  ),
                  SliverVisibility(
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        if (index == 0) {
                          return ListTile(
                            title: Text(_filter.text),
                            subtitle: Text("Artwork ID".i18n),
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) =>
                                      IllustPageLite(_filter.text)));
                            },
                          );
                        }
                        if (index == 1) {
                          return ListTile(
                            title: Text(_filter.text),
                            subtitle: Text("Artist ID".i18n),
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => UserPage(
                                        id: int.tryParse(_filter.text)!,
                                        type: ArtworkType.ALL,
                                      )));
                            },
                          );
                        }
                        if (index == 2 && _filter.text.length < 5) {
                          return ListTile(
                            title: Text(_filter.text),
                            subtitle: Text("Pixivision ID"),
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => SoupPage(
                                        url:
                                            "https://www.pixivision.net/zh/a/${_filter.text.trim()}",
                                        spotlight: null,
                                      )));
                            },
                          );
                        }
                        return ListTile();
                      }, childCount: 3),
                    ),
                    visible: idV,
                  ),
                  if (_suggestionStore.autoWords.isNotEmpty)
                    SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final tags = _suggestionStore.autoWords;
                        return ListTile(
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
                              Navigator.of(context, rootNavigator: true)
                                  .push(MaterialPageRoute(builder: (context) {
                                if (type == ArtworkType.NOVEL) {
                                  return NovelResultPage(
                                    word: tags[index].name,
                                    translatedName:
                                        tags[index].translatedName ?? "",
                                  );
                                }
                                if (type == ArtworkType.ALL) {
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
                              }));
                            }
                          },
                          title: Text(tags[index].name),
                          subtitle: Text(tags[index].translatedName ?? ""),
                        );
                      }, childCount: _suggestionStore.autoWords.length),
                    ),
                ],
              ),
            ),
          ],
        )),
      );
    });
  }

  AppBar _buildAppBar(context) {
    return AppBar(
      title: _textField(context, TextInputType.text, focusNode),
      iconTheme:
          IconThemeData(color: Theme.of(context).textTheme.bodyLarge!.color),
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.close,
              color: Theme.of(context).textTheme.bodyLarge!.color),
          onPressed: () {
            _filter.clear();
          },
        ),
        DropdownButton(
          value: type,
          iconSize: 0,
          items: [
            DropdownMenuItem(
                value: ArtworkType.ILLUST,
                child: Text(
                  "Artwork".i18n,
                  style: TextStyle(fontSize: 16),
                )),
            DropdownMenuItem(
                value: ArtworkType.NOVEL,
                child: Text(
                  "Novel".i18n,
                  style: TextStyle(fontSize: 16),
                )),
            DropdownMenuItem(
                value: ArtworkType.ALL,
                child: Text(
                  "User".i18n,
                  style: TextStyle(fontSize: 16),
                )),
          ],
          onChanged: (ArtworkType? value) {
            setState(() {
              type = value!;
            });
          },
        ).paddingRight(10),
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
        cursorColor: Theme.of(context).iconTheme.color,
        style: Theme.of(context)
            .textTheme
            .titleMedium!
            .copyWith(color: Theme.of(context).iconTheme.color),
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
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: "Enter keywords or links".i18n,
        ));
  }
}

class SuggestionStore {
  ObservableList<Tag> autoWords = ObservableList();
  fetch(String query) async {
    try {
      ConnectManager()
          .apiClient
          .getSearchAutoCompleteKeywords(query)
          .then((value) {
        if (!value.success) throw BadRequestException("Network error");
        autoWords.clear();
        autoWords.addAll(value.data);
      });
    } catch (e) {
      BotToast.showText(text: e.toString());
    }
  }

  @override
  String toString() {
    return '''
autoWords: $autoWords
    ''';
  }

  ReactiveContext get context => mainContext;
}
