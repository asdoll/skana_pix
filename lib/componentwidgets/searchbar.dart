import 'package:flutter/material.dart';
import 'package:moon_design/moon_design.dart';
import 'package:skana_pix/componentwidgets/chip.dart';
import 'package:skana_pix/view/userview/userpage.dart';
import 'package:skana_pix/controller/search_controller.dart';
import 'package:skana_pix/model/worktypes.dart';
import 'package:get/get.dart';
import 'package:skana_pix/utils/leaders.dart';
import 'package:skana_pix/view/imageview/imagelistview.dart';
import 'package:skana_pix/view/imageview/imagesearchresult.dart';
import 'package:skana_pix/view/novelview/novelpage.dart';
import 'package:skana_pix/view/novelview/novelresult.dart';
import 'package:skana_pix/view/souppage.dart';
import 'package:skana_pix/view/userview/usersearch.dart';

class SearchBar1 extends StatefulWidget {
  final ArtworkType type;
  const SearchBar1(this.type, {super.key});

  @override
  State<SearchBar1> createState() => _SearchBar1State();
}

class _SearchBar1State extends State<SearchBar1> {
  late TextEditingController filter;
  late SuggestionStore suggestionStore;
  FocusNode focusNode = FocusNode();

  @override
  void initState() {
    suggestionStore = Get.put(SuggestionStore());
    filter = TextEditingController(text: "");
    super.initState();
  }

  @override
  void dispose() {
    Get.delete<SuggestionStore>();
    filter.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => MoonDropdown(
          show: suggestionStore.showMenu.value,
          distanceToTarget: 0,
          constrainWidthToChild: true,
          decoration: BoxDecoration(
            color: context.moonColors!.goku,
            borderRadius:
                const BorderRadius.vertical(bottom: Radius.circular(8.0)),
            border: Border(
              left: BorderSide(color: context.moonColors!.beerus),
              right: BorderSide(color: context.moonColors!.beerus),
              bottom: BorderSide(color: context.moonColors!.beerus),
            ),
          ),
          onTapOutside: () => suggestionStore.showMenu.value = false,
          content: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: context.height/2),
              child: ListView(
                padding: EdgeInsets.all(0),
                children: [
                  MoonMenuItem(
                    onTap: () {
                      onSubmit(filter.text);
                    },
                    label: Text(filter.text),
                  ),
                  if (suggestionStore.tagGroup.isNotEmpty)
                    MoonMenuItem(
                      onTap: () {},
                      label: Wrap(
                        spacing: 5,
                        children: [
                          for (String i in suggestionStore.tagGroup)
                            PixChip(
                                f: i,
                                type: "search",
                                onTap: () {
                                  final start = filter.text.indexOf(i);
                                  if (start != -1) {
                                    filter.selection =
                                        TextSelection.fromPosition(TextPosition(
                                            offset: start + i.length));
                                  }
                                })
                        ],
                      ),
                    ),
                  if (suggestionStore.idv.value)
                    MoonMenuItem(
                      onTap: (){},
                      label: Wrap(
                        spacing: 5,
                        children: [
                          PixChip(
                            f: "Artwork ID".tr,
                            type: "search",
                            onTap: () {
                              Get.to(() => IllustPageLite(filter.text),
                                  preventDuplicates: false);
                            },
                          ),
                          PixChip(
                            f: "Novel ID".tr,
                            type: "search",
                            onTap: () {
                              Get.to(() => NovelPageLite(filter.text),
                                  preventDuplicates: false);
                            },
                          ),
                          PixChip(
                            f: "Artist ID".tr,
                            type: "search",
                            onTap: () {
                              Get.to(
                                  () => UserPage(
                                      id: int.tryParse(filter.text)!,
                                      type: ArtworkType.ALL),
                                  preventDuplicates: false);
                            },
                          ),
                          if (filter.text.length < 5)
                            PixChip(
                              f: "Pixivision".tr,
                              type: "search",
                              onTap: () {
                                Get.to(
                                    () => SoupPage(
                                        url:
                                            "https://www.pixivision.net/zh/a/${filter.text.trim()}",
                                        spotlight: null),
                                    preventDuplicates: false);
                              },
                            ),
                        ],
                      ),
                    ),
                  for (var tag in suggestionStore.autoWords)
                    MoonMenuItem(
                      label: Text(tag.name),
                      content: tag.translatedName != null
                          ? Text(tag.translatedName!)
                          : null,
                      onTap: () => onSubmit(tag.name),
                    ),
                ],
              ),
          ),
          child: MoonTextInput(
            hintText: suggestionStore.type.value == ArtworkType.ILLUST
                ? 'Search Illust or Manga'.tr
                : suggestionStore.type.value == ArtworkType.NOVEL
                    ? 'Search Novel'.tr
                    : 'Search User'.tr,
            controller: filter,
            borderRadius: suggestionStore.showMenu.value
                ? const BorderRadius.vertical(top: Radius.circular(8))
                : null,
            onTap: () {
              if (!suggestionStore.showMenu.value && filter.text.isEmpty){
                return;
              }
              suggestionStore.showMenu.value = !suggestionStore.showMenu.value;
              suggestionStore.fetch(filter.text);
            },
            onChanged: (String _) {
              suggestionStore.showMenu.value = true;
              suggestionStore.query.value = filter.text;
              suggestionStore.tagGroup.clear();
              var tags = suggestionStore.query.value
                  .split(" ")
                  .map((e) => e.trim())
                  .takeWhile((value) => value.isNotEmpty);
              if (tags.length > 1) suggestionStore.tagGroup.addAll(tags);
              suggestionStore.tagGroup.refresh();
              suggestionStore.idv.value =
                  int.tryParse(suggestionStore.query.value) != null;
              if (suggestionStore.query.value.startsWith('https://')) {
                Leader.pushWithUri(
                    context, Uri.parse(suggestionStore.query.value));
                filter.clear();
                return;
              }
              var word = suggestionStore.query.value.trim();
              if (word.isEmpty) {
                suggestionStore.autoWords.clear();
                suggestionStore.autoWords.refresh();
                suggestionStore.showMenu.value = false;
                return;
              }
              if (suggestionStore.idv.value && word.length > 5)
                return; //超过五个数字应该就不需要给建议了吧
              word = tags.last;
              if (word.isEmpty) {
                suggestionStore.autoWords.clear();
                suggestionStore.autoWords.refresh();
                suggestionStore.showMenu.value = false;
                return;
              }
              suggestionStore.fetch(word);
            },
            leading: const Icon(MoonIcons.generic_search_24_light),
            trailing: MoonButton.icon(
              padding: EdgeInsets.zero,
              hoverEffectColor: Colors.transparent,
              onTap: () {
                filter.clear();
                suggestionStore.query.value = "";
                suggestionStore.showMenu.value = false;
              },
              icon: const Icon(MoonIcons.controls_close_24_light),
            ),
          ),
        ));
  }

  void onSubmit(String s) {
    var word = s.trim();
    if (word.isEmpty) return;
    Get.to(() {
      if (suggestionStore.type.value == ArtworkType.NOVEL) {
        return NovelResultPage(
          word: word,
        );
      }
      if (suggestionStore.type.value == ArtworkType.USER) {
        return UserResultPage(
          word: word,
        );
      }
      return IllustResultPage(
        word: word,
      );
    }, preventDuplicates: false);
  }
}
